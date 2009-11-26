require 'rubygems'
require 'activerecord'
require 'sinatra'
require 'sass'
require 'twilio'

load 'config/config.rb'
load 'models.rb'
load 'methods.rb'
load 'config/twilio_conf.rb'

module Reminderer
  class App < Sinatra::Default
    set :sessions, true
    set :run, false

    before do
      @flash = get_flash.nil? ? "" : "<span class='flash'>#{get_flash}</span>"  
    end

    get '/style.css' do
      content_type 'text/css'
      sass :style
    end

    get '/' do
      haml :index
    end
    
    get "/init_call" do
      @phone = "6122721534"
      Twilio::Call.make('6122464910', @phone, 'http://dev.looce.com:4567/make_call')
      haml :index
    end
    
    post "/make_call" do
      @task = "talk to that one person"
      verb = Twilio::Verb.new { |v|
        v.say("This is a reminder call from Reminderer. Please remember to: #{@task}")
        v.pause(:length => 1)
        v.say("Thank you. Good bye.")
        v.hangup
      }
      verb.response
    end
    
    get "/search_records" do
      fetch_records
      haml :index
    end
    
    post "/add_reminder" do
      reminder = Reminder.new
      parsed = parse_reminder(params[:task], params[:timezone])
      
      reminder.task = parsed.first
      reminder.time = parsed.last
      reminder.phone = params[:phone]

      reminder.save
    end

  end
end