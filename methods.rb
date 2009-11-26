require 'rubygems'
require 'haml'
require 'open-uri'

def get_flash
  flash = request.cookies["flash"]
  response.delete_cookie("flash")
  return flash  
end

def set_flash(message)
  response.set_cookie("flash", :value => message, :path => '/')
end

def partial(template, *args)
  options = args.extract_options!
  options.merge!(:layout => false)
  if collection = options.delete(:collection) then
    collection.inject([]) do |buffer, member|
      buffer << haml(template, options.merge(
                                :layout => false, 
                                :locals => {template.to_sym => member}
                              )
                   )
    end.join("\n")
  else
    haml(template, options)
  end
end

def parse_time(timezone, text)
  response = open("http://www.timeapi.org/#{timezone}/#{text}").read
end

def parse_reminder(raw, timezone)  
  atSplit = raw.split(" at ")
  inSplit = raw.split(" in ")
  
  if atSplit.length == 2
    return atSplit[0], parse_time(timezone, "#{atSplit[1]}")
  end
  if inSplit.length == 2
    return inSplit[0], parse_time(timezone, "#{inSplit[1]}")
  end
end


