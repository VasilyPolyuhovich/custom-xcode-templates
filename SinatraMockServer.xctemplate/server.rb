require 'rubygems'
require 'active_support/core_ext'
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/streaming'
require 'json'
require 'rabl'
require 'haml'

class TestServer < Sinatra::Base

  self.app_file = __FILE__

  configure :development do
    use Rack::Logger
    set :logging, true
    register Sinatra::Reloader
  end

  configure do
    set :logging, true
    set :dump_errors, true
    puts "#{root}"
    set :public_folder, Proc.new { File.expand_path(File.join(root, 'fixtures')) }
    set :haml, :format=>:html5
    Rabl.register!
  end

  Rabl.configure do |config|
    config.include_json_root = false
    config.include_child_root = false
  end

  helpers Sinatra::Streaming
  helpers do    
    def rabl(template)
      render :rabl, template, :format=>:json
    end

    def render_fixture(filename)
      send_file File.join(settings.public_folder, filename)
    end

    def logger
      return request.logger
    end
  end
  
  get '/' do
    render_fixture('fixture1.json')
  end 

  # Return a 503 response to test error conditions
  get '/offline' do
    status 503
  end

  # Simulate a JSON error
  get '/error' do
    status 400
    content_type 'application/json'
    {:error=>"An error occurred!!"}.to_json
  end

  #start the server if ruby file executed directly
  run! if app_file == $0
end


