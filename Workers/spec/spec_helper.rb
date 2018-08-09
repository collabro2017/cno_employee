require 'bundler'
require 'mock_redis'

Bundler.require(:default, :test)

# Require all code classes
Dir[File.dirname(__FILE__) + '/../lib/**/*.rb'].each { |file| require file }

RSpec.configure do |config|
  config.color = true
  config.fail_fast = true

  # Mock Redis on every instance
  config.before(:each) do
    redis_class = class_double("Redis").as_stubbed_const()
    allow(redis_class).to receive(:new).and_return(MockRedis.new)
  end

  # Fakefs tags
  config.include FakeFS::SpecHelpers, fakefs: true
end
