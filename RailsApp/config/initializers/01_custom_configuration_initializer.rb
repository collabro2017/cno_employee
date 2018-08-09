rails_config = CNO::RailsApp.config
reloader = CNO::Configuration::Reloader

#
reloader.def('mailer_config') do
  if (setting = rails_config.custom.mailer_config)
    [rails_config.action_mailer, ActionMailer::Base].each do |config|
      config.raise_delivery_errors = setting.raise_delivery_errors
      config.smtp_settings = setting.smtp_settings.to_h.symbolize_keys
    end
  end
end

reloader.def('yell_config') do
  if (yell = rails_config.custom.yell_config)
    yell_config = if defined?(ActiveSupport::HashWithIndifferentAccess)
                    ActiveSupport::HashWithIndifferentAccess.new(yell.to_h)
                  else
                    yell.to_h
                  end

    Rails.logger = Yell.new(yell_config[Rails.env] || {})
  end
end

reloader.def('resque_config') do
  full_config = rails_config.custom.resque_config
  env_config = full_config[Rails.env] unless full_config.nil?
  unless env_config.nil?
    Resque.redis = env_config.redis_host
    Resque::Plugins::Status::Hash.expire_in = env_config.resque_status_expire_in
  end
end

reloader.def('force_ssl') do
  if (force_ssl = rails_config.custom.force_ssl)
    rails_config.force_ssl = force_ssl
  end
end

reloader.def('redis_session_store_config') do
  full_config = rails_config.custom.redis_session_store_config
  env_config = full_config[Rails.env].to_h.symbolize_keys unless full_config.nil?
  unless env_config.nil?
    rails_config.session_store :redis_session_store, env_config
  end
end

# Added this for now until mail setup is figured out
# Custom config hash is in custom_configuration table.
# Not sure if the config for this table in intialized somewhere or if it was just setup manually through console.
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = { address: 'localhost' }