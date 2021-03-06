#!/usr/bin/env ruby
require 'net/http'
require 'json'

require 'learnosity/sdk/request/init'

security_packet = {
	# XXX: This is a Learnosity Demos consumer; replace it with your own consumer key
	'consumer_key'   => 'yis0TYCu7U9V4o7M',
	'domain'         => 'localhost'
}
# XXX: The consumer secret should be in a properly secured credential store, and *NEVER* checked in in revision control
consumer_secret = '74c5fd430cf1242a527f6223aebd42d30464be22'
data_request = { 'limit' => 1 }

# Do 5 subsequent requests using the `next` pointer
[1,2,3,4,5].each  do |reqno|
	init = Learnosity::Sdk::Request::Init.new(
		'data',
		security_packet,
		consumer_secret,
		data_request
	)

	request = init.generate

	itembankUri = URI('https://data.learnosity.com/v1/itembank/items')
	puts ">>> [#{itembankUri} (#{reqno})] #{JSON.generate(request)}"

	res = Net::HTTP.post_form(itembankUri, request)

	puts "<<< [#{res.code}] #{res.body}"

	response = JSON.parse(res.body)
	if ( !response['meta']['next'].nil? \
			and !response['meta']['records'].nil? and response['meta']['records'] > 0)
		data_request['next'] = response['meta']['next']
	end
end
