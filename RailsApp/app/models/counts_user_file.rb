class CountsUserFile < ActiveRecord::Base
  belongs_to :count
  belongs_to :user_file
  belongs_to :concrete_field

  validates_presence_of :count
  validates_presence_of :user_file
  validates_presence_of :concrete_field

  validates :user_file,
    uniqueness: {
      scope:   :count,
      message: "you already have a suppression with this file"
    }
end

