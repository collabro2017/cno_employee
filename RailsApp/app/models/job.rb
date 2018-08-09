require 'chronic_duration'

class Job < ActiveRecord::Base
  prepend ChainJobStatus
  include MemoryStatus

  QUEUE = "central_#{Application::VERSION}"

  classy_enum_attr :status, enum: 'JobStatus', default: :created
  delegate :active?, to: :status

  belongs_to :count
  delegate :datasource, to: :count
  
  belongs_to :order
  belongs_to :user

  has_many :order_statistics

  def self.by_company(company_id)
    joins(:user).where("users.company_id = ?", company_id)
  end

  # TO-DO: extract to its own module
  # Definition of tidy timestamp methods
  column_names.each do |column_name|
    if column_name.end_with?("_at")
      method = "tidy_#{column_name}".to_sym
      define_method(method) do |use_article = false|
        tidy_at(self.send(column_name), use_article)            
      end   
    end
  end

  def enqueue
    self.save if self.new_record?

    begin
      class_name = self.class.name.demodulize
      Resque::Plugins::Status::Hash.create(self.id, options: self.payload)

      if Resque.enqueue_to(QUEUE, class_name, self.id, self.payload)
        mark_as :queued
      else
        #TO-DO: Log error here when cannot enqueue job
        Resque::Plugins::Status::Hash.remove(self.id)
      end
    rescue StandardError => e
      #TO-DO: Log error here when cannot enqueue job
      raise e
    end
  end

  def payload
    raise NotImplementedError
  end
 
  def base_payload
    unless defined?(@payload)
      record_key = self.datasource.concrete_fields.find_by(record_key: true)
      @payload = {
        header: {
          domain:        CNO::RailsApp.config.custom.domain.downcase,
          count_id:      self.count.id,
          job_id:        self.id,
          datasource:    self.datasource.name,
          total_records: self.datasource.total_records,
          has_radius?:   count.has_radius?,
          record_key: {
            field_id:        record_key.position,
            field_name:      record_key.field.name,
            exclude?:        nil,
            linked_to_next?: false
          }
        }
      }
      @payload[:selects] = selects_data
      @payload[:dedupes] = dedupes_data
      @payload[:suppress_order] = suppress_order_data
      @payload[:suppress_file] = suppress_file_data
    end

    @payload
  end

  def mark_as(new_status)
    self.status = new_status
    self.public_send("#{new_status}_at=", redis_time)
    save
  end
  
  # Total elapsed time since the job was created
  def total_time(options = {format: :short, keep_zero: true})
    if self.raw_total_time.present?
      ChronicDuration.output(self.raw_total_time.round, options)
    end
  end

  def raw_total_time
    ret = nil
    if status == :failed
      ret = (failed_at - created_at)
    elsif status == :killed
      ret = (killed_at - created_at)
    elsif status == :completed
      ret = (completed_at - created_at)
    elsif active?
      ret = (Time.now - created_at)
    end
    ret
  end

  # TO-DO: include into the STI module methods
  def type_as_sym
    self.type.demodulize.underscore
  end

  def self.type_from_sym(sym)
    "#{self.to_s.pluralize}::#{sym.to_s.camelize}"
  end

  def save_result_values
    self.total_count = resque_status['result']
    save
    self.count.result = self.total_count
    self.count.save
  end

  private
    def selects_data
      count.selects.active.map do |select|
        data = {
          select_id:             select.id,
          field_id:              select.concrete_field.position,
          ui_data_type:          select.ui_data_type.to_s,
          db_data_type:          select.db_data_type.to_s,
          has_values?:           select.has_values,
          has_ranges?:           select.has_ranges,
          has_blanks_criterion?: select.has_blanks_criterion,
          exclude?:              select.exclude,
          has_files?:            select.has_files,
          linked_to_next?:       select.active_linked_to_next?
        }

        if select.has_ranges?
          data[:range_from] = select.from 
          data[:range_to] = select.to
        end

        data[:blanks] = select.blanks if select.has_blanks_criterion?

        if select.has_files?
          data[:files] = select.user_files.map do |file|
                           {
                             id:         file.id,
                             user_email: file.user.email,
                             name:       file.name
                           }
                         end
        end

        data
      end
    end

    def dedupes_data
      count.dedupes.map do |dedupe|
        {
          dedupe_id:       dedupe.id,
          field_id:        dedupe.concrete_field.position,
          ui_data_type:    dedupe.concrete_field.ui_data_type.to_s,
          distinct_count:  dedupe.concrete_field.distinct_count,
          tiebreak:        dedupe.tiebreak,
          conflict_values: dedupe.concrete_field.conflict_values
        }
      end
    end

    def suppress_order_data
      count.suppression_orders.map do |order|
        # Assuming there one and only one concrete field with record_key = true
        record_key = order.datasource.concrete_fields.find_by(record_key: true)

        {
          id: order.id,
          datasource: order.datasource.name,
          record_key: {
            field_id:   record_key.position,
            field_name: record_key.field.name
          },
          suppress?: true # In case we add the ability to 'append' as 
                          # alternative to suppress this value would be false
        }
      end
    end

    def suppress_file_data
      count.counts_user_files.map do |count_suppress|
        {
          id:         count_suppress.user_file.id,
          user_email: count_suppress.user_file.user.email,
          name:       count_suppress.user_file.name,
          criteria: {
            field_id:      count_suppress.concrete_field.position,
            field_name:    count_suppress.concrete_field.name,
            source_fields: count_suppress.concrete_field.source_fields
          },
          suppress?: true # In case we add the ability to 'append' as 
                          # alternative to suppress this value would be false
        }
      end
    end

    #TO-DO: specs for this method & include timezone logic & extract to module
    def tidy_at(date, use_article)
      ret = nil
      if date
        article = "on"
        if Time.now.to_date == date.to_date
          if (Time.now - date).to_i < 60
            article = ""
            ret = "less than one minute ago"
          else
            article = "today at"
            ret = date.strftime("%l:%M %P").strip
          end
        elsif Time.now.year == date.year
          ret = date.strftime("%b #{date.day.ordinalize}").squeeze
        else
          ret = date.strftime("%Y-%m-%d")
        end
        if use_article
          ret = "#{article} #{ret}"
        end
      end
      ret
    end

end
