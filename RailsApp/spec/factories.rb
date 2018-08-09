FactoryGirl.define do 
  factory :user do
    sequence (:first_name) { |n| "Person#{("A".."ZZZ").to_a[n]}" }
    sequence (:email) { |n| "person_#{n}@example.com" }
    password 'password'
    password_confirmation 'password'
    company { FactoryGirl.create(:company) }
  end

  factory :datasource do
    name { guaranteed_unique_symbol(32) }
  end

  factory :field do
    # Since the caption is generated from the name, it could get expanded and
    # fail the <64 validation. That's why we aren't using the maximum allowed.
    name { guaranteed_unique_symbol(48) }
  end
  
  factory :concrete_field do
    association :datasource, factory: :datasource
    association :field, factory: :field
  end
  
  factory :select_option do
  end

  factory :field_category do
  end

  factory :count_old do
    name { guaranteed_unique_symbol (32) }
    result nil
    user
    datasource
  end

  factory :job do
  end

  factory :count_job, class: Jobs::Count do
  end

  factory :breakdown_job, class: Jobs::Breakdown do
  end

  factory :order do
    count { FactoryGirl.create(:count) }
  end

  factory :zip5, class: Lookups::Custom::Zip5 do
  end
  
  factory :select do
    count { FactoryGirl.create(:count) }
    concrete_field { FactoryGirl.create(:concrete_field) }    
  end
  
  factory :breakdown do
    count { FactoryGirl.create(:count) }
    concrete_field { FactoryGirl.create(:concrete_field) }
  end

  factory :count do
    name { guaranteed_unique_symbol (32) }
    user { FactoryGirl.create(:user) }
    datasource { FactoryGirl.create(:datasource) }
  end

  factory :sortable_group_dummy do
  end

  factory :sortable_dummy do
    sortable_group_dummy { FactoryGirl.create(:sortable_group_dummy) }
  end

  factory :output do
    order { FactoryGirl.create(:order) }
    concrete_field { FactoryGirl.create(:concrete_field) }
  end

  factory :dedupe do
    count { FactoryGirl.create(:count) }
    concrete_field { FactoryGirl.create(:concrete_field) }
  end

  factory :default_lookup_model_builder do
    ignore do
      concrete_field { FactoryGirl.create(:concrete_field) }
    end
    initialize_with { DefaultLookupModelBuilder.new(concrete_field) }
  end
  
  factory :lookup_option do
    lookup_class_name { "Lookups::LookupDummy" }
  end

  factory :binary_string_value do
    concrete_field { FactoryGirl.create(:concrete_field) }
  end

  factory :binary_integer_value do
    concrete_field { FactoryGirl.create(:concrete_field) }
  end

  factory :company do
    name { guaranteed_unique_symbol(32) }
    code { guaranteed_unique_symbol(32) }
  end

  factory :concrete_field_input_method do
    concrete_field { FactoryGirl.create(:concrete_field, ui_data_type: :binary)}
    input_method_type :binary
  end

  factory :field_input_method do
    field { FactoryGirl.create(:field)}
    input_method_type :binary
  end
end
