require 'field_caption'

class Field < ActiveRecord::Base
  
  has_many :datasources_fields
  has_many :datasources,
      through: :datasources_fields,
      before_add: :validates_datasource

  validates :name,
    presence: true,
    format: { with: /\A[a-z0-9_]+\z/ },
    length: { maximum: 64, too_long: "%{count} characters maximum" }

  validates :caption,
    length: { maximum: 64, too_long: "%{count} characters maximum" }

  scope :with_categories, -> { includes(:categories) }

  def caption
    name.present? ? FieldCaption.generate(name) : ""
  end

  private

    def validates_datasource(datasource)
      raise ActiveRecord::Rollback if self.datasources.include? datasource
    end

end
