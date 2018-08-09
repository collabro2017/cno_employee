require 'erb'
require 'yaml'
require 'yell'

class Configuration

  def self.environment
    return @@environment if defined?(@@environment)

    @@environment = (ENV['ENV'] || 'development')
  end

  def self.db_config
    return @@db_config if defined?(@@db_config)
      
    database_file = "#{File.dirname(__FILE__)}/../config/database.yml"
    @@db_config = 
        YAML.load(ERB.new(File.read(database_file)).result)[self.environment]
  end

  def self.paths
    return @@paths if defined?(@@paths)

    paths_file = "#{File.dirname(__FILE__)}/../config/paths.yml"
    @@paths =
        YAML.load(ERB.new(File.read(paths_file)).result)[self.environment] 
  end

  def self.numbers
    return @@numbers if defined?(@@numbers)

    numbers_file = "#{File.dirname(__FILE__)}/../config/numbers.yml"
    @@numbers =
        YAML.load(ERB.new(File.read(numbers_file)).result)[self.environment] 
  end

  def self.logger
    return @@logger if defined?(@@logger)
    Yell.load! "#{File.dirname(__FILE__)}/../config/yell.yml"
  end

end