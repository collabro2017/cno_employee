class Order < ActiveRecord::Base

  MAX_ORDER_SIZE = 300_000

  belongs_to :user
  belongs_to :count, inverse_of: :orders

  has_and_belongs_to_many :suppressing_counts, class_name: 'Count'

  has_many :jobs

  #-----------------------------------------------------------------------------
  # TO-DO: move this into a concern. This is for letting the model know there
  # were changes in the nested attributes.

  attr_accessor :outputs_changed
  attr_accessor :sorts_changed
  
  def report_change(object)
    if(object.is_a?(Output))
      self.outputs_changed = true
    elsif(object.is_a?(Sort))
      self.sorts_changed = true
    end
  end

  def outputs_changed?
    outputs_changed || outputs.map(&:changed?).include?(true)
  end

  def sorts_changed?
    sorts_changed || sorts.map(&:changed?).include?(true)
  end

  has_many :outputs,
           -> { order("position") },
           after_add: :report_change,
           after_remove: :report_change
  accepts_nested_attributes_for :outputs, allow_destroy: true

  has_many :sorts,
           -> { order("position") },
           after_add: :report_change,
           after_remove: :report_change
  accepts_nested_attributes_for :sorts, allow_destroy: true
  #=============================================================================

  classy_enum_attr :cap_type, default: :total_cap
  
  validates_presence_of :count

  validate :count_has_been_run, on: :create
  validate :count_is_active, on: :create
  validate :count_is_not_dirty, on: :create

  validates :po_number,
              length: {
                maximum: 16,
                too_long: "cannot be more than %{count} letter(s) long"
              }

  validates :total_cap,
    presence: true,
    numericality: { only_integer: true }
  validate :total_cap_cannot_exceed_max
  
  delegate :datasource, to: :count
  delegate :allowed_for_user?, to: :count

  after_create :set_initial_output_layout
  before_validation :set_max_total_cap, on: :create

  def self.by_company(company_id)
    joins(:user).where("users.company_id = ?", company_id)
  end

  def outputs_table_names
    outputs = self.outputs.map do |output|
      caption = output.escaped_caption
      "#{output.concrete_field.column_table}_values.value as #{caption}"
    end
    outputs.join(",\n")
  end

  def order_fields
    self.outputs.map { |o| o.concrete_field.field.name }.join(',')
  end

  def last_successful_job
    self.jobs.where(status: :completed).last
  end

  def suppressing_in_count?(count_id)
    self.suppressing_counts.where(id: count_id).any?
  end

  def count_has_been_run
    unless count.result.present? && count.last_simple_count_job.present?
      errors.add(:count, "has not been run")
    end
  end

  def count_is_active
    unless self.count.selects.active.any?
      errors.add(:count, 'does not have any active selects')
    end
  end

  def count_is_not_dirty
    if self.count.dirty?
      errors.add(
        :count, 'has changed and needs to be re-run before placing an order'
      )
    end
  end

  def max_total_cap
    [MAX_ORDER_SIZE, count.result].min
  end

  private
    def set_max_total_cap
      self.total_cap = max_total_cap
    end

    def total_cap_cannot_exceed_max
      if self.total_cap.present? && self.total_cap > max_total_cap
        errors.add :total_cap, "exceeds maximum allowed"
      end
    end

    def set_initial_output_layout
      self.datasource.default_output_layout.each do |cf|
        self.outputs.find_or_create_by(concrete_field: cf) if cf.output_enabled?
      end

      self.count.selects.each do |s|
        if s.concrete_field.output_enabled?
          self.outputs.find_or_create_by(concrete_field: s.concrete_field)
        end
      end
    end

end
