require 'bundler'
require 'yaml'
require 'active_support/hash_with_indifferent_access'

Bundler.require
Dotenv.load

get '/' do
  erb :index
end

get '/example' do
  "#{make_request :example}"
end

def endpoints
  YAML.load_file("endpoints.yml").to_h.symbolize_keys!
end

def request_params endpoint
  {
    method: endpoints[endpoint]["method"].to_sym,
    url: endpoints[endpoint]["url"],
    headers: endpoints[endpoint]["headers"].symbolize_keys!,
    verify_ssl: OpenSSL::SSL::VERIFY_NONE,
#   If you require basic auth 
#   user: ENV['AUTH_USER'],
#   password: ENV['AUTH_PASSWORD'],
    payload: endpoints[endpoint]["payload"]
  }
end

def make_request endpoint
  if JSON.parse(RestClient::Request.execute(request_params(endpoint)).try(:force_encoding, 'UTF-8'))
    "The endpoint #{endpoints[endpoint]["url"]} seems to be responding"
  end
rescue RestClient::Exception
  "The endpoint #{endpoints[endpoint]["url"]} doesn't seem to be responding"
end
