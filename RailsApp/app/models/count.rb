require 'csv'

class Count < ActiveRecord::Base

  DEFAULT_NAME = "New Count"
  CONCRETE_FIELD_ASSOCIATIONS = %w(selects breakdowns dedupes)

  #-----------------------------------------------------------------------------
  # TO-DO: "summary" is not the most descriptive word here

  class Summary < ActiveRecord::Base
    self.table_name = 'count_summaries'
    belongs_to :count
  end

  has_one :summary
  delegate :user_name, :datasource_name,  
    :most_recent_job_id, :most_recent_job_status, :most_recent_job_updated_at,
    to: :summary

  #-----------------------------------------------------------------------------

  belongs_to :datasource, -> { with_deleted }
  delegate :outdated?, to: :datasource

  belongs_to :user
  belongs_to :parent, class_name: 'Count'

  has_one  :count, class_name: 'Count', foreign_key: "parent_id"
  has_many :selects
  has_many :breakdowns
  has_many :dedupes
  has_and_belongs_to_many :suppression_orders, class_name: 'Order'
  has_many :counts_user_files
  has_many :user_files, through: :counts_user_files

  validates_presence_of :user
  validates_presence_of :datasource
  validates :name,
    uniqueness: {scope:   :user,
                 message: "you already have a count with this name"},
    presence: true,
    length: {
      minimum: 1,
      too_short: "%{count} letter minimum",
      maximum: 128,
      too_long: "%{count} letter maximum"
    },
    format: {
      with: /\A[^\x00\/\\:\*\?\"<>\|]+\z/,
      message: "cannot contain any of the following characters: " + \
               "/, \\, :, *, ?, \", <, > or |"
    }
  validates :result,
    numericality: { greater_than_or_equal_to: 0},
    allow_nil: true

  has_many :jobs
  has_many :orders, inverse_of: :count

  before_validation :assign_default_name, if: :user_is_present?
  before_validation { name.strip! if name.present? }

  #-----------------------------------------------------------------------------

  def self.with_summary
    select('*').joins(:summary)
  end

  def self.filtered_sorted(params)
    scope = with_summary
    scope = by_params(scope, params)

    sort_column =
      connection.quote_column_name(params[:sort_column] || 'count_id')
    sort_direction = params[:sort_direction] || 'desc'
    scope.order("#{sort_column} #{sort_direction}")
  end

  def self.exact(column, value)
    where("#{connection.quote_column_name(column)} = ?", "#{value}")
  end

  def self.fuzzy(column, value)
    where("#{connection.quote_column_name(column)} LIKE ?", "%#{value}%")
  end

  def self.by_company(company_id)
    joins(:user).where("users.company_id = ?", company_id)
  end

  def self.by_params(scope, params)
    params.symbolize_keys.each do |param, value|
      if value.present?
        case param
        when :name
          scope = scope.fuzzy(param, value)
        when :user_name, :datasource_name
          scope = scope.exact(param, value)
        end
      end
    end
    scope
  end

  #-----------------------------------------------------------------------------

  def values_class
    if self.id
      ValuesModelBuilder.new(self.id).build_or_get_model
    end
  end

  def has_radius?
    self.values_class.where(
      select: self.selects.active.pluck(:id), 
      input_method: 'zip5_distance').any?
  end

  def last_successful_job
    self.jobs.where(status: :completed).last
  end

  def last_count_job
    self.jobs.where(
      '"type" = ? OR "type" = ?', 'Jobs::Count', 'Jobs::Breakdown'
    ).last
  end

  def last_simple_count_job
    self.jobs.where(type: Jobs::Count).last
  end

  def last_breakdown_job
    self.jobs.where(type: Jobs::Breakdown).last
  end

  def clone_job
    self.jobs.where(type: Jobs::Clone).last
  end

  def breakdown_results_class
    if self.id && last_breakdown_job.present?
      last_breakdown_job.results_class
    end
  end

  def breakdown_results_columns
    breakdown_results_class.column_names unless breakdown_results_class.nil?
  end

  def self.next_name_for(name, user_id, suffix=0)
    search_name = (suffix > 0) ? "#{name} (#{suffix})" : name

    count = Count.where(name: search_name, user_id: user_id).first

    if count
      search_name = self.next_name_for(name, user_id, (suffix+1))
    end

    search_name
  end

  def add_suppression_order(order_id)
    order = Order.find_by(id: order_id)
    self.suppression_orders << order unless order.nil?
    order
  end

  def remove_suppression_order(order_id)
    if Order.exists?(order_id)
      self.suppression_orders.delete(Order.find(order_id))
    end
  end

  def add_suffix_to_name_if_needed
    self.name = self.class.next_name_for(self.name, self.user.id)
  end

  def clone(params)
    new_count = deep_clone(:include => [ {:selects => :user_files},
                                         :breakdowns,
                                         :dedupes,
                                         :suppression_orders
                                        ],
                            :except => [:locked, :user_id, :parent_id]
                          )

    new_count.parent = self
    new_count.user = params[:user]
    new_count.datasource = params[:datasource]

    new_count.name << ' - Clone'
    new_count.add_suffix_to_name_if_needed

    new_count
  end

  def inherit_values
    # deep clone only if clone & parent datasources are the same
    if self.datasource.id == self.parent.datasource.id
      values_class # Creates the values table for the current count

      if self.parent.selects.with_values.any?
        job = Job.new(count: self, type: 'Jobs::Clone', user: self.user)
        job.enqueue
      end
    end
  end

  def set_dirty(flag)
    self.dirty = flag
    self.save
  end

  def allowed_for_user?(user_id)
    user = User.find(user_id)
    user.allowed_datasources.pluck(:id).include?(self.datasource.id)
  end

  def active_concrete_fields
    CONCRETE_FIELD_ASSOCIATIONS.each_with_object([]) do |association, accum|
      self.send(association).each { |record| accum << record.concrete_field }
    end
  end

  def check_datasource_compatibility(other_datasource)
    conflicts = []
    other_datasource_field_ids = other_datasource.fields.pluck(:id)

    active_concrete_fields.each do |cf|
      if other_datasource_field_ids.include?(cf.field.id)
        other_cf = other_datasource.concrete_fields
                    .find_by(field_id: cf.field.id)

        conflicts << cf.field.id unless cf.flags_match?(other_cf)
      else
        conflicts << cf.field.id
      end
    end

    conflicts
  end

  private
    def user_is_present?
      user.present?
    end

    def assign_default_name
      if name.nil?
        self.name = self.class.next_name_for(DEFAULT_NAME, user.id)
      end
    end
end
