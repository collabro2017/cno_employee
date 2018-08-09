# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

company = Company.create!(name: 'My Company', code: 'MC')

User.create!(
  company: company,
  first_name: 'Sys', last_name: 'Admin',
  email: 'sysadmin@pensaconsulting.com', 
  password: 'password', password_confirmation: 'password',
  status: 'active',
  sysadmin: true
)

