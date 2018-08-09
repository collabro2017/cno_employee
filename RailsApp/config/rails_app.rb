require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'aws-sdk'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module CNO
  class RailsApp < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)

    # Setup AWS class to use key information from environment variables
    AWS.config(
      access_key_id: ENV['AWS_ACCESS_ID'],
      secret_access_key: ENV['AWS_SECRET_KEY']
    )

    # > Overwriting field_error_proc for working with Twitter's Bootstap
    # Idea taken from https://gist.github.com/t2/1464315
    #config.action_view.field_error_proc = Proc.new do |html_tag, instance| 
    #  %(<span class="field_with_errors">#{html_tag}</span>).html_safe    
    #end

    # Load subfolder inside app/models
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '{**/}')]
    
    # Load contents of app/lib and subfolders
    config.autoload_paths += Dir[Rails.root.join('app', 'lib', '{**/}')]

    # Load contents of lib and subfolders
    config.autoload_paths += Dir[Rails.root.join('lib', '{**/}')]

    # Load Rails and Ruby core monkey patches
    Dir[Rails.root.join('lib', 'ext', '{**/}', '*.rb')].each do |file|
      require file
    end

    # Add two custom methods to the current Rails config attribute
    config.singleton_class.class_eval do
      def default
        CNO::Configuration::Default.load
      end

      def custom
        CNO::Configuration::Accessor.new('CustomConfiguration')
      end
    end

    config.cache_store = [:memory_store, { size: 32.megabytes }]

  end
end
