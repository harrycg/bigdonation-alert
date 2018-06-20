#!/usr/bin/env ruby

require 'mail'
require 'json'
require 'nationbuilder'
require 'slack-notifier'

client = NationBuilder::Client.new('aycc', ENV['NATIONBUILDER_APIKEY'], retries: 8)

two_days_ago = Date.today - 1
  puts "Loading donations..."
response = client.call(:donations, :index, limit: 50)
page = NationBuilder::Paginator.new(client, response)

donations = []

donations += page.body['results']

while page.next?
  page = page.next
  break unless Date.parse(donations.last['created_at']) >= two_days_ago
  donations += page.body['results']
end
  


donations.each do |d|
if d['amount_in_cents'] > 80000
 
    email = d['donor']['email']
  first_name = d['donor']['first_name']
 last_name = d['donor']['last_name']
  amount = d['amount']
  person_id = d['donor']['id']
  date = d['created_at']

    puts "BIG #{email} donated #{amount} on #{date}"

  notifier = Slack::Notifier.new ENV['SLACK'] 
notifier.ping "#{first_name} #{last_name} #{email} donated #{amount} on #{date}"
else
      email = d['donor']['email']
  first_name = d['donor']['first_name']
 last_name = d['donor']['last_name']
  amount = d['amount']
  person_id = d['donor']['id']
  date = d['created_at']
      puts "LITTLE #{email} donated #{amount} on #{date}"

end
end



   
