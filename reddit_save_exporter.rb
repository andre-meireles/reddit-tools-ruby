#!/usr/bin/ruby

require 'redd'
require 'pp'
require 'yaml'

creds = YAML.load_file('creds.yaml')

session = Redd.it(
    secret: creds["secret"],
    username: creds["username"],
    password: creds["password"],
    user_agent: creds["user_agent"],
    client_id: creds["client_id"]
)

all_saved_permalinks = []
previous_page = nil

loop do
    if previous_page == nil 
        current_page = session.me.listing("saved", { :limit => 100 })
    elsif previous_page.after == nil
        break
    else
        current_page = session.me.listing("saved", { :limit => 100, :after => previous_page.after })
    end

    if not current_page.empty?
        current_page.each do |element|
            if element.is_a?(Redd::Models::Submission)
                pp "printing element: "
                pp element
                all_saved_permalinks.push("https://www.reddit.com"+element.permalink)
            elsif element.is_a?(Redd::Models::Comment)
                all_saved_permalinks.push(element.link_permalink+element.id)
            else
                all_saved_permalinks.push("Unable to determine element type.")
            end
        end
        previous_page = current_page
    else
        break
    end
end

puts all_saved_permalinks