f = Field.create(name: "full_name_of_member_1", caption: "Full Name of Member 1", description: "Head of Household Full Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "house_number_and_street_name", caption: "House Number and Street Name", description: "Address - House number and street Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "contact_phone_number", caption: "Contact Phone Number", description: "Landline Phone Number")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "phone_number_area_code", caption: "Phone Number Area Code", description: "Phone Number Area Code")
cat = FieldCategory.find_or_create_by(name: "Geo")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "phone_number_without_area_code", caption: "Phone number without area code", description: "Phone number not including Area Code")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "city", caption: "City", description: "Residence City")
cat = FieldCategory.find_or_create_by(name: "Address")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "state", caption: "State", description: "Residence State")
cat = FieldCategory.find_or_create_by(name: "Address")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "zip", caption: "ZIP", description: "Residence Zip Code")
cat = FieldCategory.find_or_create_by(name: "Address")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "zip_4", caption: "Zip + 4", description: "Residence Zip dove plus 4 digit extension")
cat = FieldCategory.find_or_create_by(name: "Address")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "zip_4_delivery_point_bar_code", caption: "Zip + 4 + Delivery Point Bar Code", description: "Residence Zip dove plus 4 digit extension and Delivery Point Bar Code")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "delivery_point_bar_code", caption: "Delivery Point Bar Code", description: "Delivery Point Bar Code Seperated from Zip Code")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "carrier_route", caption: "Carrier Route", description: "Postal Carrier Route")
cat = FieldCategory.find_or_create_by(name: "Address")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "county", caption: "County", description: "Residence County")
cat = FieldCategory.find_or_create_by(name: "Address")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "metropolitan_statistical_area", caption: "Metropolitan Statistical Area", description: "Residence Metrpolitan Statistical Are")
cat = FieldCategory.find_or_create_by(name: "Address")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "latitude", caption: "LATITUDE", description: "LATITUDE")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "longitude", caption: "LONGITUDE", description: "LONGITUDE")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "timezone", caption: "timezone", description: "timezone")
cat = FieldCategory.find_or_create_by(name: "Address")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "census_tract", caption: "CENSUS TRACT", description: "CENSUS TRACT")
cat = FieldCategory.find_or_create_by(name: "Address")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "census_block_group", caption: "CENSUS BLOCK GROUP", description: "CENSUS BLOCK GROUP")
cat = FieldCategory.find_or_create_by(name: "Address")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "census_block", caption: "CENSUS BLOCK", description: "CENSUS BLOCK")
cat = FieldCategory.find_or_create_by(name: "Address")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "first_name", caption: "First Name", description: "Head of Household First Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "last_name", caption: "Last Name", description: "Head of Household Last Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "gender", caption: "Gender", description: "Head of Household Gender")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age", caption: "Age", description: "Head of Household Age Range (See Sheet 2 for breakdown)")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "member_2_full_name", caption: "Member 2 Full Name", description: "Member 2 Full Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_2_first_name", caption: "Member 2 First Name", description: "Member 2 First Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_2_last_name", caption: "Member 2 Last Name", description: "Member 2 Last Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_2_gender", caption: "Member 2 Gender", description: "Member 2 Gender")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "member_2_age", caption: "Member 2 Age", description: "Member 2 Age")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "member_3_full_name", caption: "Member 3 Full Name", description: "Member 3 Full Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_3_first_name", caption: "Member 3 First Name", description: "Member 3 First Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_3_last_name", caption: "Member 3 Last Name", description: "Member 3 Last Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_3_gender", caption: "Member 3 Gender", description: "Member 3 Gender")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_3_age", caption: "Member 3 Age", description: "Member 3 Age")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_4_full_name", caption: "Member 4 Full Name", description: "Member 4 Full Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_4_first_name", caption: "Member 4 First Name", description: "Member 4 First Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_4_last_name", caption: "Member 4 Last Name", description: "Member 4 Last Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_4_gender", caption: "Member 4 Gender", description: "Member 4 Gender")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_4_age", caption: "Member 4 Age", description: "Member 4 Age")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_5_full_name", caption: "Member 5 Full Name", description: "Member 5 Full Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_5_first_name", caption: "Member 5 First Name", description: "Member 5 First Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_5_last_name", caption: "Member 5 Last Name", description: "Member 5 Last Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_5_gender", caption: "Member 5 Gender", description: "Member 5 Gender")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_5_age", caption: "Member 5 Age", description: "Member 5 Age")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_6_full_name", caption: "Member 6 Full Name", description: "Member 6 Full Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_6_first_name", caption: "Member 6 First Name", description: "Member 6 First Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_6_last_name", caption: "Member 6 Last Name", description: "Member 6 Last Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_6_gender", caption: "Member 6 Gender", description: "Member 6 Gender")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_6_age", caption: "Member 6 Age", description: "Member 6 Age")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_7_full_name", caption: "Member 7 Full Name", description: "Member 7 Full Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_7_first_name", caption: "Member 7 First Name", description: "Member 7 First Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_7_last_name", caption: "Member 7 Last Name", description: "Member 7 Last Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_7_gender", caption: "Member 7 Gender", description: "Member 7 Gender")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_7_age", caption: "Member 7 Age", description: "Member 7 Age")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_8_full_name", caption: "Member 8 Full Name", description: "Member 8 Full Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_8_first_name", caption: "Member 8 First Name", description: "Member 8 First Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_8_last_name", caption: "Member 8 Last Name", description: "Member 8 Last Name")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_8_gender", caption: "Member 8 Gender", description: "Member 8 Gender")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "member_8_age", caption: "Member 8 Age", description: "Member 8 Age")
cat = FieldCategory.find_or_create_by(name: "Uncategorized")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "false")
f = Field.create(name: "generations_in_household", caption: "GENERATIONS IN HOUSEHOLD", description: "Number of generations living at household")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "marital_status_in_the_hhld", caption: "MARITAL STATUS IN THE HHLD", description: "Marital status (Single, Married, Divorced)")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "veteran_in_household", caption: "VETERAN IN HOUSEHOLD", description: "Wartime veteran living in household")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "young_adult_in_household", caption: "YOUNG ADULT IN HOUSEHOLD", description: "Adult aged 18 - 25 living in household")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "senior_adult_in_household", caption: "SENIOR ADULT IN HOUSEHOLD", description: "Adult aged 65+ living in household")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "christian_families", caption: "CHRISTIAN FAMILIES", description: "Religious christian family")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "working_woman", caption: "WORKING WOMAN", description: "Female holding management level and above position in the workplace")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "african_american_professionals", caption: "AFRICAN AMERICAN PROFESSIONALS", description: "African American with management level and of above position in the work place")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "dwelling_type", caption: "Dwelling Type", description: "Dwelling Definition (Single family, Multi family, etc…)")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "property_type", caption: "PROPERTY TYPE", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "years_since_home_was_built", caption: "Years since home was built", description: "Age of home structure")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "estimated_home_value", caption: "Estimated Home Value", description: "Home value (Based on Assessed value)")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "estimated_income", caption: "Estimated Income", description: "Household Income (Derived from survey data. Both online and offline sourcing / Value Range)")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "net_worth", caption: "Net Worth", description: "Net Worth (Derived from survey data and calculated based on known assets for validity / Value Range)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "community_reinvestment_act", caption: "COMMUNITY REINVESTMENT ACT ", description: "CRA Classification Code -See sheet 2 for breakdown")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "infered_credit", caption: "Infered_Credit", description: "Inferred Credit Rank (Values) ")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "lines_of_credit", caption: "LINES OF CREDIT", description: "Inferred lines of available credit (Numeric value 0 -10)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "available_new_credit", caption: "AVAILABLE NEW CREDIT", description: "Inferred availaible credit (Dollar Value in ranges)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "membership_clubs", caption: "MEMBERSHIP CLUBS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "american_express_gold_premium", caption: "AMERICAN EXPRESS GOLD/PREMIUM", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "american_express_regular", caption: "AMERICAN EXPRESS REGULAR", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "discover_gold_premium", caption: "DISCOVER GOLD/PREMIUM", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "discover_regular", caption: "DISCOVER REGULAR", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "gasoline_or_retail_card_gold_pre", caption: "GASOLINE OR RETAIL CARD GOLD/PREMIUM", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "gasoline_or_retail_card_regular", caption: "GASOLINE OR RETAIL CARD REGULAR", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "mastercard_gold_premium", caption: "MASTERCARD GOLD/PREMIUM", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "mastercard_regular", caption: "MASTERCARD REGULAR", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "visa_gold_premium", caption: "VISA GOLD/PREMIUM", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "visa_regular", caption: "VISA REGULAR", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "bank_card_holder", caption: "BANK CARD HOLDER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "gas_department_retail_card_holde", caption: "GAS/DEPARTMENT/RETAIL CARD HOLDER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "travel_and_entertainment_card_ho", caption: "TRAVEL AND ENTERTAINMENT CARD HOLDER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "credit_card_holder_unknown_type", caption: "CREDIT CARD HOLDER - UNKNOWN TYPE", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "premium_card_holder", caption: "PREMIUM CARD HOLDER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "upscale_department_store_card_ho", caption: "UPSCALE (DEPARTMENT STORE) CARD HOLDER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "credit_card_user", caption: "CREDIT CARD USER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "credit_card_new_issue", caption: "CREDIT CARD - NEW ISSUE", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "bank_card_presence_in_household", caption: "BANK CARD - PRESENCE IN HOUSEHOLD", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "ownership_rent", caption: "Ownership/Rent", description: "Owner or Renter Indicator")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "number_of_years_in_residence", caption: "Number of years in residence", description: "Years of family in household")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "air_conditioning", caption: "AIR CONDITIONING", description: "Air Conditioning type - See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "fuel", caption: "Fuel", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "sewer", caption: "SEWER", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "water", caption: "WATER", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "loan_to_value", caption: "LOAN TO VALUE ", description: "Loan to Value ratio of home (Value is based on assesed value)")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "current_age_of_mortgage", caption: "Current age of mortgage", description: "Years since mortgage started")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "purchase_date", caption: "PURCHASE DATE  ", description: "Date of home purchase (CCYYMMDD)")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "purchase_price", caption: "PURCHASE PRICE", description: "Purchase price of home (Dollar amount)")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "1st_mortgage_amount", caption: "1st MORTGAGE AMOUNT", description: "First mortgage amount (Dollar Amount Range)")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "2nd_mortgage_amount", caption: "2ND MORTGAGE AMOUNT", description: "Second mortgage amount (Dollar Amount Range)")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "1st_mortgage_date", caption: "1st MORTGAGE DATE", description: "Date of first mortgage")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "2nd_recent_mortgage_date", caption: "2ND RECENT MORTGAGE DATE", description: "Date of second mortgage")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "1st_mortgage_loan_type_code", caption: "1ST MORTGAGE LOAN TYPE CODE", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "2nd_mortgage_loan_type_code", caption: "2ND MORTGAGE LOAN TYPE CODE", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "1st_mortgage_loan_type_code", caption: "1ST MORTGAGE LOAN TYPE CODE", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "2nd_mortgage_loan_type_code", caption: "2ND MORTGAGE LOAN TYPE CODE", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "1st_lender_name", caption: "1ST LENDER NAME", description: "Lender Name on Mortgage 1 - See Lender Descriptions Tab 5")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "2nd_recent_lender_name", caption: "2ND RECENT LENDER NAME", description: "Lender Name on Mortgage 2 - See Lender Descriptions Tab 5")
cat = FieldCategory.find_or_create_by(name: "Property")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "automotive_auto_parts_and_access", caption: "AUTOMOTIVE, AUTO PARTS AND ACCESSORIES ", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "apparel_womens", caption: "APPAREL - WOMEN'S", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "apparel_womens_petite", caption: "APPAREL - WOMEN'S - PETITE", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "apparel_womens_plus_sizes", caption: "APPAREL - WOMEN'S - PLUS SIZES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "young_womens_apparel", caption: "YOUNG WOMEN'S APPAREL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "apparel_mens", caption: "APPAREL - MEN'S", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "apparel_mens_big_and_tall", caption: "APPAREL - MEN'S - BIG AND TALL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "young_mens_apparel", caption: "YOUNG MEN'S APPAREL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "apparel_hildrens", caption: "APPAREL HILDREN'S", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "health_and_beauty", caption: "HEALTH AND BEAUTY", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "beauty_cosmetics", caption: "BEAUTY/COSMETICS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "jewelry", caption: "JEWELRY", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "luggage", caption: "LUGGAGE", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "books_and_magazines_magazines", caption: "BOOKS AND MAGAZINES - MAGAZINES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "books_and_music_books", caption: "BOOKS AND MUSIC - BOOKS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "books_and_music_books_audio", caption: "BOOKS AND MUSIC - BOOKS - AUDIO", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "reading_general", caption: "READING - GENERAL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "reading_religious_inspirational", caption: "READING - RELIGIOUS / INSPIRATIONAL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "reading_science_fiction", caption: "READING - SCIENCE FICTION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "reading_magazines", caption: "READING - MAGAZINES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "reading_audio_books", caption: "READING - AUDIO BOOKS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "reading_financial_newsletter_sub", caption: "READING - FINANCIAL NEWSLETTER SUBSCRIBERS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "reading_grouping", caption: "READING GROUPING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "history_military", caption: "HISTORY / MILITARY", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "current_affairs_politics", caption: "CURRENT AFFAIRS / POLITICS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "religious_inspirational", caption: "RELIGIOUS / INSPIRATIONAL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "science_space", caption: "SCIENCE / SPACE", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "magazines", caption: "MAGAZINES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "home_living", caption: "HOME LIVING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "diy_living", caption: "DIY LIVING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "sporty_living", caption: "SPORTY LIVING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "upscale_living", caption: "UPSCALE LIVING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "cultural_artistic_living", caption: "CULTURAL/ARTISTIC LIVING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "highbrow", caption: "HIGHBROW", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "high_tech_living", caption: "HIGH-TECH LIVING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "common_living", caption: "COMMON LIVING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "professional_living", caption: "PROFESSIONAL LIVING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "broader_living", caption: "BROADER LIVING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "antiques", caption: "ANTIQUES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "art", caption: "ART", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "theater_performing_arts", caption: "THEATER / PERFORMING ARTS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "arts", caption: "ARTS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "musical_instruments", caption: "MUSICAL INSTRUMENTS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "childrens_apparel_infants_and_to", caption: "CHILDREN'S APPAREL - INFANTS AND TODDLERS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "childrens_learning_and_activity_", caption: "CHILDREN'S LEARNING AND ACTIVITY TOYS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "childrens_products_general_baby_", caption: "CHILDREN'S PRODUCTS - GENERAL - BABY CARE", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "childrens_products_general_back_", caption: "CHILDREN'S PRODUCTS - GENERAL - BACK-TO-SCHOOL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "childrens_products_general", caption: "CHILDREN'S PRODUCTS - GENERAL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "childrens_interests", caption: "CHILDREN'S INTERESTS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "collectibles_general", caption: "COLLECTIBLES - GENERAL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "collectibles_stamps", caption: "COLLECTIBLES - STAMPS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "collectibles_coins", caption: "COLLECTIBLES - COINS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "collectibles_arts", caption: "COLLECTIBLES - ARTS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "collectibles_antiques", caption: "COLLECTIBLES - ANTIQUES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "collector_avid", caption: "COLLECTOR - AVID", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "collectibles_and_antiques_groupi", caption: "COLLECTIBLES AND ANTIQUES GROUPING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "collectibles_sports_memorabilia", caption: "COLLECTIBLES - SPORTS MEMORABILIA", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "military_memorabilia_weaponry", caption: "MILITARY MEMORABILIA/WEAPONRY", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "lifestyles_interests_and_passion", caption: "LIFESTYLES, INTERESTS AND PASSIONS COLLECTIBLES ", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "cooking_food_grouping", caption: "COOKING / FOOD GROUPING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "foods_natural", caption: "FOODS - NATURAL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "food_wines", caption: "FOOD - WINES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "cooking_gourmet", caption: "COOKING - GOURMET", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "cooking_general", caption: "COOKING - GENERAL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "computing_home_office_general", caption: "COMPUTING/HOME OFFICE - GENERAL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "dvds_videos", caption: "DVDS/VIDEOS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "electronics_and_computing_tv_vid", caption: "ELECTRONICS AND COMPUTING - TV/VIDEO/MOVIE WATCHER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "electronics_computing_and_home_o", caption: "ELECTRONICS, COMPUTING AND HOME OFFICE ", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "high_end_appliances", caption: "HIGH END APPLIANCES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "intend_to_purchase_hdtv_satellit", caption: "INTEND TO PURCHASE - HDTV/SATELLITE DISH", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "music_home_stereo", caption: "MUSIC - HOME STEREO", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "music_player", caption: "MUSIC PLAYER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "music_collector", caption: "MUSIC COLLECTOR", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "music_avid_listener", caption: "MUSIC - AVID LISTENER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "movie_collector", caption: "MOVIE COLLECTOR", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "tv_cable", caption: "TV - CABLE", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "games_video_games", caption: "GAMES - VIDEO GAMES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "tv_satellite_dish", caption: "TV - SATELLITE DISH", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "computers", caption: "COMPUTERS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "games_computer_games", caption: "GAMES - COMPUTER GAMES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "consumer_electronics", caption: "CONSUMER ELECTRONICS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "movie_music_grouping", caption: "MOVIE / MUSIC GROUPING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "electronics_computers_grouping", caption: "ELECTRONICS / COMPUTERS GROUPING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "telecommunications", caption: "TELECOMMUNICATIONS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "travel_grouping", caption: "TRAVEL GROUPING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "travel", caption: "TRAVEL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "travel_domestic", caption: "TRAVEL - DOMESTIC", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "travel_international", caption: "TRAVEL - INTERNATIONAL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "travel_cruise_vacations", caption: "TRAVEL - CRUISE VACATIONS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "spectator_sports_auto_motorcycle", caption: "SPECTATOR SPORTS - AUTO / MOTORCYCLE RACING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "spectator_sports_tv_sports", caption: "SPECTATOR SPORTS - TV SPORTS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "spectator_sports_football", caption: "SPECTATOR SPORTS - FOOTBALL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "spectator_sports_baseball", caption: "SPECTATOR SPORTS - BASEBALL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "spectator_sports_basketball", caption: "SPECTATOR SPORTS - BASKETBALL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "spectator_sports_hockey", caption: "SPECTATOR SPORTS - HOCKEY", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "spectator_sports_soccer", caption: "SPECTATOR SPORTS - SOCCER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "tennis", caption: "TENNIS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "golf", caption: "GOLF", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "snow_skiing", caption: "SNOW SKIING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "scuba_diving", caption: "SCUBA DIVING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "motorcycling", caption: "MOTORCYCLING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "nascar", caption: "NASCAR", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "boating_sailing", caption: "BOATING / SAILING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "sports_and_leisure", caption: "SPORTS AND LEISURE", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "sports_grouping", caption: "SPORTS GROUPING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "online_purchasing_indicator", caption: "ONLINE PURCHASING INDICATOR", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "value_priced_general_merchandise", caption: "VALUE-PRICED GENERAL MERCHANDISE", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "sewing_knitting_needlework", caption: "SEWING / KNITTING / NEEDLEWORK", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "woodworking", caption: "WOODWORKING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "photography", caption: "PHOTOGRAPHY", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "aviation", caption: "AVIATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "house_plants", caption: "HOUSE PLANTS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "crafts", caption: "CRAFTS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "home_and_garden", caption: "HOME AND GARDEN", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "gardening", caption: "GARDENING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "gardening2", caption: "GARDENING2", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "home_improvement_grouping", caption: "HOME IMPROVEMENT GROUPING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "lifestyles_interests_and_passion", caption: "LIFESTYLES, INTERESTS AND PASSIONS RAFTS/HOBBIES ", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "photography_and_video_equipment", caption: "PHOTOGRAPHY AND VIDEO EQUIPMENT", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "home_furnishings_decorating", caption: "HOME FURNISHINGS / DECORATING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "home_improvement", caption: "HOME IMPROVEMENT", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "intend_to_purchase_home_improvem", caption: "INTEND TO PURCHASE - HOME IMPROVEMENT", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "gaming", caption: "GAMING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "games_board_games_puzzles", caption: "GAMES - BOARD GAMES / PUZZLES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "gaming_casino", caption: "GAMING - CASINO", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "sweepstakes_contests", caption: "SWEEPSTAKES / CONTESTS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "pets", caption: "PETS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "equestrian", caption: "EQUESTRIAN", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "other_pet_owner", caption: "OTHER PET OWNER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Purchasing")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "donor_type1", caption: "Donor_Type1", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "donor_type2", caption: "Donor_Type2", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "donor_type3", caption: "Donor_Type3", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "donor_type4", caption: "Donor_Type4", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "donor_type5", caption: "Donor_Type5", description: "See Genearl Field Definitions")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "donation_contribution", caption: "DONATION/CONTRIBUTION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "mail_order_donor", caption: "MAIL ORDER DONOR", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "charitable_donation", caption: "CHARITABLE  DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "animal_welfare_charitable_donati", caption: "ANIMAL WELFARE  CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "arts_or_cultural_charitable_dona", caption: "ARTS OR CULTURAL CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "childrens_charitable_donation", caption: "CHILDREN'S  CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "environment_or_wildlife_charitab", caption: "ENVIRONMENT OR WILDLIFE  CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "environmental_issues_charitable_", caption: "ENVIRONMENTAL ISSUES  CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "health_charitable_donation", caption: "HEALTH  CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "international_aid_charitable_don", caption: "INTERNATIONAL AID  CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "political_charitable_donation", caption: "POLITICAL  CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "political_conservative_charitabl", caption: "POLITICAL - CONSERVATIVE  CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "political_liberal_charitable_don", caption: "POLITICAL - LIBERAL  CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "religious_charitable_donation", caption: "RELIGIOUS  CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "veterans_charitable_donation", caption: "VETERAN'S  CHARITABLE DONATION", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "other_types_of_charitable_donati", caption: "OTHER TYPES OF CHARITABLE DONATIONS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "community_charities", caption: "COMMUNITY / CHARITIES", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "ethnic", caption: "ETHNIC", description: "See Ethnic Descriptions Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "ethnic_confidence", caption: "ETHNIC-CONFIDENCE", description: "See Ethnic Descriptions Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "ethnic_group", caption: "Ethnic Group", description: "See Ethnic Descriptions Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "language", caption: "LANGUAGE", description: "See Ethnic Descriptions Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "religion", caption: "RELIGION", description: "See Ethnic Descriptions Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hispanic_country_of_origin", caption: "HISPANIC COUNTRY OF ORIGIN", description: "See Ethnic Descriptions Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "assimilation", caption: "ASSIMILATION", description: "See Ethnic Descriptions Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "education", caption: "EDUCATION", description: "See Ethnic Descriptions Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "education_online", caption: "EDUCATION ONLINE", description: "See Ethnic Descriptions Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "occupation", caption: "OCCUPATION", description: "See Occupation Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "business_owner", caption: "BUSINESS OWNER", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "cellular_phone_number", caption: "Cellular Phone Number", description: "Wireless Cellular Phone Number")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "cellular_carrier", caption: "Cellular Carrier", description: "Wireless Cellular Carrier")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_year1", caption: "Auto_Year1", description: "Automobile Year of Vehicle 1")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_make1", caption: "Auto_Make1", description: "Automobile Make of Vehicle 1")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_model1", caption: "Auto_Model1", description: "Automobile Model of Vehicle 1")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_year2", caption: "Auto_Year2", description: "Automobile Year of Vehicle 2")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_make2", caption: "Auto_Make2", description: "Automobile Make of Vehicle 2")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_model2", caption: "Auto_Model2", description: "Automobile Model of Vehicle 2")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_year3", caption: "Auto_Year3", description: "Automobile Year of Vehicle 3")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_make3", caption: "Auto_Make3", description: "Automobile Make of Vehicle 3")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_model3", caption: "Auto_Model3", description: "Automobile Model of Vehicle 3")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_year4", caption: "Auto_Year4", description: "Automobile Year of Vehicle 4")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_make4", caption: "Auto_Make4", description: "Automobile Make of Vehicle 4")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_model4", caption: "Auto_Model4", description: "Automobile Model of Vehicle 4")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_year5", caption: "Auto_Year5", description: "Automobile Year of Vehicle 5")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_make5", caption: "Auto_Make5", description: "Automobile Make of Vehicle 5")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "auto_model5", caption: "Auto_Model5", description: "Automobile Model of Vehicle 5")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "moto_year", caption: "Moto_Year", description: "Motorcycle Year")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "moto_make", caption: "Moto_Make", description: "Motorcycle Make")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "moto_model", caption: "Moto_Model", description: "Motorcycle Model")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "mh_year", caption: "MH_Year", description: "Mobile Home Year")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "mh_class", caption: "MH_Class", description: "Mobile Home Class")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "pwc_year", caption: "PWC_Year", description: "Personal Watercraft Year")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "pwc_make", caption: "PWC_Make", description: "Personal Watercraft Make")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "pwc_model", caption: "PWC_Model", description: "Personal Watercraft Model")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "model_xdate", caption: "Model_Xdate", description: "Modelled Insurance Expiration Date")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "boat_man", caption: "Boat_Man", description: "See Watercraft Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "boat_year", caption: "Boat_Year", description: "See Watercraft Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "std_use", caption: "STD_Use", description: "See Watercraft Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hull_shape", caption: "Hull_Shape", description: "See Watercraft Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hull_mat", caption: "Hull_Mat", description: "See Watercraft Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "prop_type", caption: "Prop_Type", description: "See Watercraft Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "boat_fuel", caption: "Boat Fuel", description: "See Watercraft Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "boat_type", caption: "Boat_Type", description: "See Watercraft Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "size_class", caption: "Size_Class", description: "See Watercraft Sheet")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "comp_own", caption: "Comp_Own", description: "Computer owned and in the Household")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "paydayapp", caption: "PayDayApp", description: "Has applied for a Pay Day Loan in the last 180 days")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "home_based_business", caption: "Home Based Business", description: "An Incorporated Business located at the Home Address")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "career_improvement", caption: "CAREER IMPROVEMENT", description: "See General Field Definitions")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "career", caption: "CAREER", description: "See General Field Definitions")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "college_student", caption: "College Student", description: "College Student present within the household")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "debt_cons", caption: "Debt Cons", description: "Has applied for a Debt Consolidation in the last 180 days")
cat = FieldCategory.find_or_create_by(name: "General")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "gamblers", caption: "Gamblers", description: "Land Based or Online Gambler present within the household")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "health_enthusiast", caption: "Health Enthusiast", description: "Health Enthusiast (Active Gym Member, Heathy Eater)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "exercise_running_jogging", caption: "EXERCISE - RUNNING / JOGGING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "exercise_walking", caption: "EXERCISE - WALKING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "exercise_aerobic", caption: "EXERCISE - AEROBIC", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "dieting_weight_loss", caption: "DIETING / WEIGHT LOSS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "health_medical", caption: "HEALTH/MEDICAL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "self_improvement", caption: "SELF IMPROVEMENT", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "investments_personal", caption: "INVESTMENTS - PERSONAL", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "investments_real_estate", caption: "INVESTMENTS - REAL ESTATE", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "investments_stocks_bonds", caption: "INVESTMENTS - STOCKS / BONDS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "investing_finance_grouping", caption: "INVESTING / FINANCE GROUPING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "investments_foreign", caption: "INVESTMENTS - FOREIGN", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "investment_estimated_residential", caption: "INVESTMENT - ESTIMATED RESIDENTIAL PROPERTIES OWNED", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "money_seekers", caption: "MONEY SEEKERS", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "bizop", caption: "BizOp", description: "Business Opportunity Seeker")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "outdoorsmen", caption: "Outdoorsmen", description: "Hunter/Fisher/Camping in Household")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hunting", caption: "HUNTING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "fishing", caption: "FISHING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "camping_hiking", caption: "CAMPING / HIKING", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "mag_subscriber", caption: "Mag Subscriber", description: "Currently has a Magazine Subscription")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "diy_home", caption: "DIY_Home", description: "Do-It Yourself Home - Household that does general home maintence rather than hiring a contractor")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "diy_auto", caption: "DIY_Auto", description: "Do-It Yourself Auto - Handles general maintenance of vehicle rather than taking to a mechanic")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "ailment", caption: "Ailment", description: "Chronic pain sufferer")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "presence_of_children", caption: "Presence_of_Children", description: "Children under 18 years of age present in the household")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "single_parent", caption: "SINGLE PARENT", description: "Indicator Field (Populated with 'X' if present)")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_00_02_male", caption: "Age 00 - 02 Male", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_00_02_female", caption: "Age 00 - 02 Female", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_00_02_unknown_gender", caption: "Age 00 - 02 Unknown Gender", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_03_05_male", caption: "Age 03 - 05 Male", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_03_05_female", caption: "Age 03 - 05 Female", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_03_05_unknown_gender", caption: "Age 03 - 05 Unknown Gender", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_06_10_male", caption: "Age 06 - 10 Male", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_06_10_female", caption: "Age 06 - 10 Female", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_06_10_unknown_gender", caption: "Age 06 - 10 Unknown Gender", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_11_15_male", caption: "Age 11 - 15 Male", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_11_15_female", caption: "Age 11 - 15 Female", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_11_15_unknown_gender", caption: "Age 11 - 15 Unknown Gender", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_16_17_male", caption: "Age 16 - 17 Male", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_16_17_female", caption: "Age 16 - 17 Female", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "age_16_17_unknown_gender", caption: "Age 16 - 17 Unknown Gender", description: "Number of children present in the household within age range")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "grandchildren", caption: "GRANDCHILDREN", description: "Grandchild present in household")
cat = FieldCategory.find_or_create_by(name: "HH")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "racing_enthusiast", caption: "Racing_Enthusiast", description: "Has displayed interest in a form of racing (F1, NHRA, IHRA, NASCAR, etc…)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "tobacco_user", caption: "Tobacco_User", description: "Smoker in the household")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "alcohol_user", caption: "Alcohol_User", description: "Alcohol Drinker in the household")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "vision_impaired", caption: "Vision_Impaired", description: "Glasses/Contact user in the household")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "insurance_purchaser_flag", caption: "Insurance_Purchaser_Flag", description: "Insurance policy holder (Does not include Home or Auto insurance) (This is a modeled field, using socio - economic status, Income/Net-worth, and Census Block ID) ")
cat = FieldCategory.find_or_create_by(name: "Financial")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "vehicle_maintenance", caption: "Vehicle_Maintenance", description: "Keeps regular maintenance of vehicle")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "online_ticket_purchaser", caption: "Online_Ticket_Purchaser", description: "Has purchased tickets online within the last 18 months (Concerts, sporting Events, etc…)")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "movie_ticket_purchaser", caption: "Movie_Ticket_Purchaser", description: "Has Purchased Movie tickets online within the last 18 months")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "technology_rank", caption: "Technology_Rank", description: "Rank of 1 - 10 on how up to date a household is with technology ")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hh_exp_total", caption: "HH_Exp_Total", description: "Total Houhold Expenditures - Modeled Field")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hh_exp_utilities", caption: "HH_Exp_Utilities", description: "Household Expenditures for Utilities")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hh_exp_food", caption: "HH_Exp_Food", description: "Household Expenditures for Food")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hh_exp_alcohol", caption: "HH_Exp_Alcohol", description: "Household Expenditures for Alcohol")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hh_exp_apparel", caption: "HH_Exp_Apparel", description: "Household Expenditures for Apparel")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hh_exp_transportation", caption: "HH_Exp_Transportation", description: "Household Expenditures for transportation")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hh_exp_health_care", caption: "HH_Exp_Health_Care", description: "Household Expenditures for Health Care")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hh_exp_retail", caption: "HH_Exp_Retail", description: "Household Expenditures for Retail")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hh_exp_non_retail", caption: "HH_Exp_Non_Retail", description: "Household Expenditures for Non Retail")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hh_exp_gifts", caption: "HH_Exp_Gifts", description: "Household Expenditures for Gifts")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
f = Field.create(name: "hh_exp_misc", caption: "HH_Exp_Misc", description: "Household Expenditures for Misc")
cat = FieldCategory.find_or_create_by(name: "Interests")
f.field_categories << cat
f.datasources_fields.create(datasource_id: datasources[0].id, filterable: "true")
