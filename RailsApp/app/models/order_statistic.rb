class OrderStatistic < ActiveRecord::Base

  belongs_to :job
  belongs_to :concrete_field

end
