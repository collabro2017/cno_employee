require 'erb'
class Select < ActiveRecord::Base

  SUMMARY_LENGTH = 200
  ACTIVE_FLAGS = %w[values ranges blanks_criterion files]
  RANGE_SUMMARY_FORMAT =  '[%s - %s]'

  belongs_to :count
  belongs_to :concrete_field
  has_and_belongs_to_many :user_files

  validates_presence_of :count
  validates_presence_of :concrete_field

  validates :from,
    numericality: {
      only_integer: true
    },
    allow_nil: true

  validates :to,
    numericality: {
      only_integer: true
    },
    allow_nil: true

  classy_enum_attr :blanks, enum: 'SelectBlanks', allow_nil: true

  delegate :values_class, to: :count
  delegate :caption,
           :db_data_type,
           :ui_data_type,
           :default_lookup_class,
           :binary_on_value,
           :binary_off_value,
           :valid_min,
           :valid_max,
           :input_methods,
           to: :concrete_field

  include Sortable
  self.scope_attribute = :count

  after_initialize :defaults
  before_save :fix_range_values
  before_save :reset_blanks, if: :unnecessary_non_blanks?
  before_update :update_flags, if: :select_criteria_changed?
  before_destroy :unlink_previous
  
  def self.active
    condition = ACTIVE_FLAGS.map { |flag| "has_#{flag} = ?" }.join(' OR ')
    where(condition, *ACTIVE_FLAGS.map { true })
  end

  def self.with_values
    where(has_values: true)
  end

  def add_value(value:, input_method:, lookup_params: nil)
    value = validated_value(value)

    new_value_attributes = {
                             select: self,
                             input_method: input_method,
                             :"#{value_column}" => value
                           }
    added_value = values_class.find_by(new_value_attributes)
 
    if added_value.nil?
      new_value_attributes['lookup_params'] = lookup_params
      added_value = values_class.create!(new_value_attributes)
      update_flags
    end

    added_value
  end

  def remove_value(value:, input_method:)
    if self.saved_values
      to_remove = self.saved_values.find_by(
                    self.value_column => value, :input_method => input_method
                  )

      update_flags if to_remove && to_remove.destroy
    end
    
    to_remove
  end

  # TO-DO: long method needs refactoring
  def add_multiple_lookup_values(relation, column_name, input_type, lookup_params)
    if relation.empty?
      false
    else
      column_type = relation.model.columns_hash[column_name.to_s].type

      if column_type.to_s == self.db_data_type.to_s || column_type.to_s == 'text'
        self.save if self.new_record? #to get an id

        column_names =  [ "select_id",
                          self.value_column,
                          "input_method",
                          "lookup_params"
                        ]
        column_names = quoted_column_names(column_names)

        # Creation of temporary table
        values_sql = relation.select("#{column_name}").to_sql
        tmp_name = ('a'..'z').to_a.shuffle[0,16].join

        # Query that adds the lookups params to the selected values
        tmp_table_sql = <<-END_SQL.strip_heredoc
          CREATE TABLE \"process\".#{tmp_name} AS (#{values_sql});
          ALTER TABLE #{tmp_name} ADD lookup_params json;
          UPDATE #{tmp_name} SET lookup_params = '#{lookup_params}'::json;
        END_SQL
        self.values_class.connection.execute(tmp_table_sql)

        values_sql =<<-END_SQL.strip_heredoc
          SELECT #{self.id}, #{column_name}, '#{input_type}', lookup_params
          FROM #{tmp_name} tmp
        END_SQL

        # Query that finds out which values are already added
        quoted_value_col = quoted_column_names(["#{self.db_data_type}_value"])
        existing_sql = self.values_class.select(nil)
          .where(select: self, input_method: "#{input_type}")
          .where(
              "#{self.values_class.quoted_table_name}.#{quoted_value_col}"\
              " = "\
              "tmp.#{column_name}"
            ).to_sql

        # Query that inserts
        insert_sql = <<-END_SQL.strip_heredoc
          INSERT INTO #{self.values_class.quoted_table_name}
          (#{column_names})
            #{values_sql}
          WHERE NOT EXISTS (#{existing_sql})
        END_SQL

        self.values_class.connection.insert(insert_sql)
        self.values_class.connection.execute("DROP TABLE #{tmp_name}")
        update_flags
        true
      else
        raise TypeError,
          "expected #{relation.model.table_name}'s #{column_name} column " + \
          "to be of type '#{self.db_data_type}' instead of '#{column_type}'"
      end
    end
  end

  def remove_multiple_lookup_values(scope=nil,
                                    column_name=nil,
                                    lookup_type,
                                    lookup_params)
    ret = nil

    if scope.nil? && self.saved_values.present?
      ret = self.saved_values.send(lookup_type.to_sym).delete_all
    else
      ret = joined_scoped_values(scope, column_name).delete_all
    end

    update_flags
    ret
  end

  def add_multiple_enter_values(values)
    ret = false
    values = values.nil? ? [] : split_and_clean_values(values)

    unless values.empty?
      ret = true
      self.save if self.new_record? #to get an id

      if self.db_data_type.integer?
        values.map! { |value| try_to_convert_to_integer(value) }
      end

      new_values = values - self.values_class
          .where(select: self, input_method: 'enter_value')
          .where("#{self.value_column} IN (?)", values)
          .pluck("#{self.value_column}")

      unless new_values.empty?
        column_names = ["select_id", self.value_column, "input_method"]
        insert_sql = <<-END_SQL.strip_heredoc
          INSERT INTO #{self.values_class.quoted_table_name}
            (#{quoted_column_names(column_names)})
          VALUES
            #{Array.new(new_values.size, "  (?, ?, ?)").join(",\n")}
        END_SQL

        flat_values = new_values.map{ |v| [self.id, v, 'enter_value'] }.flatten
        sql_array = [insert_sql] + flat_values
        sanitized_insert_sql = self.values_class.send(
                                 :sanitize_sql_array, sql_array
                               )
        self.values_class.connection.insert sanitized_insert_sql
        update_flags
      end
    end

    ret
  end

  def saved_values
    if count.present? && values_class.present?
      values_class.where(select: self)
    end
  end

  def saved_binary_value
    if ui_data_type == 'binary'
      if saved_values.count == 0
        nil
      elsif saved_values.count == 1
        saved_values.first.send(value_column)
      else
        raise 'a binary select should NOT have more than one saved value'
      end
    else
      raise "invalid method call for a #{ui_data_type} select"
    end
  end

  def saved_lookup_values(scope, column_name)
    joined_scoped_values(scope, column_name)
  end

  def summary
    [
      blanks_summary,
      range_summary,
      values_summary,
      files_summary
    ].compact.join(' + ')
  end

  def value_column
    "#{self.db_data_type}_value".to_sym
  end

  def range
    fix_range_values
    { from: self.from, to: self.to }
  end

  def reset_range
    self.from = self.concrete_field.valid_min
    self.to = self.concrete_field.valid_max
    self.has_ranges = false
    true
  end

  def reset_blanks
    self.blanks = nil
    self.has_blanks_criterion = false
    true
  end

  def is_active?
    ACTIVE_FLAGS.each do |flag|
      return true if self.send("has_#{flag}?")
    end
    false
  end

  def reset_exclude
    self.exclude = false
  end

  def add_user_file(user_file_id)
    # Usage of 'find_by' instead of 'find' is because 'find_by' returns nil
    # while 'find' raises a RecordNotFound error if the record isn't found
    user_file = UserFile.uploaded.find_by(id: user_file_id)
    unless user_file.nil?
      self.user_files << user_file
      update_flags
      user_file
    end
  end

  def remove_user_file(user_file_id)
    user_file = self.user_files.find_by(id: user_file_id)
    unless user_file.nil?
      self.user_files.delete(user_file)
      update_flags
      user_file
    end
  end

  def can_link?
    next_can_link = (self.next && self.next.concrete_field.can_link?)
    self.concrete_field.can_link? && next_can_link
  end

  def enum_at_first_of_group
    current = self

    while current.previous.present? && current.previous.linked_to_next?
      current = current.previous
    end

    if current.linked_to_next?
      self.count.selects.enumerator_stopped_at { |s| s.id == current.id }
    else
      raise 'select does not belong to a group'
    end
  end

  # If the next select is not active, get its 'active_linked_to_next?' value
  def active_linked_to_next?
    if self.next.present? && !self.next.is_active?
      self.next.active_linked_to_next?
    else
      self.linked_to_next?
    end
  end

  def link_to_next
    self.can_link? && self.update(linked_to_next: true)
  end

  def unlink_from_group
    last = self
    last = last.next while last.present? && last.linked_to_next?

    if (self == last) && self.previous.present?
      self.previous.update(linked_to_next: false)
    end

    self.update(position: last.position, linked_to_next: false)
  end

  private
    # Value add and removal ----------------------------------------------------
    def validated_value(value)
      if db_data_type == 'integer' && /\A[+-]?\d+\z/ === value
        value = value.to_i
      end

      type_class = db_data_type.to_s.camelize.constantize
      if value.is_a?(type_class)
        value
      else
        raise TypeError, "expected #{type_class} but received #{value.class}"
      end
    end

    def values_condition
      if self.has_values?
        self.save if self.new_record? #to get an id

        values_table = self.count.values_class.quoted_table_name
        values_column = "#{values_table}.#{self.db_data_type}_value"
        condition = "#{values_table}.select_id = #{self.id}"

        ret = self.concrete_field.select_query_values_condition
        ret = ret % [values_table, values_column, values_column, condition]
      end
    end

    def joined_scoped_values(scope, column_name)
      unless self.values_class.nil? || scope.nil? || scope.empty?
        values_table_name =  self.values_class.quoted_table_name
        values_column_name = quoted_column_names([self.value_column])
        scope_column_name = quoted_column_names([column_name])

        join_sql = <<-END_SQL
          INNER JOIN (
              #{scope.select(column_name).to_sql}
            ) s
          ON
            #{values_table_name}.#{values_column_name} = s.#{scope_column_name}
            OR (
                 #{values_table_name}.#{values_column_name} IS NULL
                 AND
                 s.#{scope_column_name} IS NULL
               )
        END_SQL

        self.saved_values.joins(join_sql)
      else
        self.saved_values.where("1 = 0") # none
      end
    end

    # TO-DO: we should move this kind of methods into a single gem RB-Misc, so 
    #       we can share it between app and workers
    def split_and_clean_values(values)
      ["\t",";","\n"].each do |delimiter|
        values.gsub!(delimiter, ',')
      end
      values.split(',').map(&:strip).reject(&:blank?)
    end

    def try_to_convert_to_integer(value)
      if /\A[+-]?\d+\z/ === value
        value.to_i
      else
        raise TypeError, "#{value} cannot be converted to integer"
      end
    end

    def quoted_column_names(column_names)
      conn = self.class.connection
      column_names.map { |column| conn.quote_column_name column }.join(', ')
    end
    #---------------------------------------------------------------------------

    # Changes tracking ---------------------------------------------------------
    def select_criteria_changed?
      !(changes.keys & %w[blanks from to]).empty?
    end

    def update_flags
      self.has_values = saved_values.any?
      self.has_ranges = (default_range != range)
      self.has_blanks_criterion = ['blanks', 'non_blanks'].include?(blanks.to_s)
      self.has_files = !self.user_files.empty?
      self.count.set_dirty(true)
      true
    end

    def default_range
      {from: concrete_field.valid_min, to: concrete_field.valid_max}
    end
    #---------------------------------------------------------------------------

    # Summary ------------------------------------------------------------------
    def values_summary
      if self.has_values?
        values = saved_values.order(value_column)
            .limit(SUMMARY_LENGTH)
            .distinct
            .pluck(value_column)

        values.map! { |value| concrete_field.format_value(value) }
        values.to_sentence(last_word_connector: ' and ')[0...SUMMARY_LENGTH]
      end
    end

    def range_summary
      if self.has_ranges?
        values = [self.from.to_s, self.to.to_s]
        if ui_data_type == 'date'
          values.map! { |v| Date.parse(v).strftime("%Y/%m/%d") }
        end
        RANGE_SUMMARY_FORMAT % values
      end
    end

    def blanks_summary
      self.blanks.present? ? "(#{self.blanks.to_s.humanize})" : nil
    end

    def files_summary
      total_files = self.user_files.count
      if total_files == 1
        "1 file"
      elsif total_files > 1
        "#{total_files} files"
      end
    end
    #---------------------------------------------------------------------------

    # after_initialize hook methods:
    def defaults
      # TO-DO: Check why this call to default_lookup_class is required upon
      # initialization. Either remove or add a comment explaining.
      self.default_lookup_class if self.concrete_field.present?

      self.has_values = false if has_values.nil?
      self.has_ranges = false if has_ranges.nil?
      self.has_blanks_criterion = false if has_blanks_criterion.nil?
    end

    # before_save hook methods
    def fix_range_values
      self.from ||= concrete_field.valid_min
      self.to ||= concrete_field.valid_max
      true
    end

    def unnecessary_non_blanks?
      (has_values? || has_ranges?) && (blanks.to_s == 'non_blanks')
    end

    # before_destroy hook methods
    def unlink_previous
      if !self.linked_to_next? && self.previous.present?
        self.previous.update(linked_to_next: false)
      end
    end
end
