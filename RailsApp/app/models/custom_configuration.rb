class CustomConfiguration < ActiveRecord::Base
  include ConfigurationStore
  include JSONWrapper

  acts_as_configuration_store
  wrap_json_columns :value

  after_save :reload_settings

  private
    def reload_settings
      setting = self[:parameter]
      if CNO::Configuration::Reloader.respond_to?(setting)
        CNO::Configuration::Reloader.send(setting)
      end
    end

end
