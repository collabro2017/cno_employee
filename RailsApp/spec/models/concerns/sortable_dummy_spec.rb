require 'spec_helper'
require 'temping'

Temping.create :sortable_group_dummy

Temping.create :sortable_dummy do
  belongs_to :sortable_group_dummy
 
  include Sortable
  self.scope_attribute = :sortable_group_dummy
  
  with_columns do |t|
    t.integer :position
    t.references :sortable_group_dummy
  end
end

describe Sortable do
  subject(:sortable) { FactoryGirl.build(:sortable_dummy) }
  it_behaves_like "sortable", :sortable_group_dummy
end
