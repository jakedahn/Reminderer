require 'rubygems'
require 'sinatra'

namespace 'db' do
  desc "Create db schema"
  task :create do        
    require 'activerecord'
    require 'config/config.rb'
  
    ActiveRecord::Migration.create_table :reminders do |t|
      t.string :task
      t.string :phone
      t.string :time
      
      t.timestamps
    end
    
  end  
end