class Reminder < ActiveRecord::Base
  validates_presence_of :task
end
