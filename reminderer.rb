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

    post "/make_call" do
      puts params[:task]
      verb = Twilio::Verb.new { |v|
        v.say("This is a reminder call from Reminderer. Please remember to: #{params[:task]}")
        v.pause(:length => 1)
        v.say("Thank you. Good bye.")
        v.hangup
      }
      verb.response
    end

    get "/search_records" do
      @reminders = Reminder.all(:conditions => ["time < ?", Time.now])
      
      @reminders.each do |reminder|
        Net::HTTP.post_form(URI.parse('http://looce.com:4567/make_call'), {'task'=> "#{reminder.task}", 'phone' => reminder.phone})
        # Twilio::Call.make('6122464910', reminder.phone, 'http://looce.com:4567/make_call')
        Twilio::Call.make('6122464910', reminder.phone, "http://looce.com:4567/make_call?task=#{reminder.task.gsub(' ', '%20')}")
      end
      
      haml :reminders
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