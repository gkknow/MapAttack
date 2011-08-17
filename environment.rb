# Encoding.default_internal = 'UTF-8'
require "rubygems"
require "bundler"
Bundler.setup
Bundler.require

class Sinatra::Base
  configure do
    # register Sinatra::Synchrony
    if test?
      set :sessions, false
    else
      set :sessions, true
      set :session_secret,  'PUT SECRET HERE'
    end
    set :root, File.expand_path(File.join(File.dirname(__FILE__)))
    set :public, File.join(root, 'public')
    set :display_errors, false
    mime_type :woff, 'application/octet-stream'
    Dir.glob(File.join(root, 'models', '**/*.rb')).each { |f| require f }
    config_hash = YAML.load_file(File.join(root, 'config.yml'))[environment.to_s]
    raise "in config.yml, the \"#{environment.to_s}\" configuration is missing" if config_hash.nil?
    GA_ID = config_hash['ga_id']
    APPLICATION_ACCESS_TOKEN = config_hash['oauth_token']
    # Faraday.default_adapter = :em_synchrony
    Geoloqi.config :client_id => config_hash['client_id'],
                   :client_secret => config_hash['client_secret'],
                   :use_hashie_mash => true
    DataMapper.finalize
    DataMapper.setup :default, ENV['DATABASE_URL'] || config_hash['database']
    # DataMapper.auto_upgrade!
    DataMapper::Model.raise_on_save_failure = true
  end
end

require File.join(Sinatra::Base.root, 'controller.rb')
