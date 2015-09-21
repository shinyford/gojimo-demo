#! /usr/bin/env ruby

require 'net/http'
require 'rubygems'
require 'sinatra'
require 'json'

# not_found do
#   halt(404, "PI doesn't know this ditty\n") unless request.path.match(/^(\/(images|css)\/.*)$/)
#
#  	url = $1
#  	filename = URI.unescape("#{Dir.pwd}/public" + url)
#   puts ">>>> Reading from #{url}"
# 	data = read_from_pi(url)
#
#   dirname = File.dirname(filename)
#   FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
#   File.open(filename, 'w') { |f| f.write(data.body) }
# 	redirect request.path
# end

def read_from_interwebs(url)
  uri = URI.parse(url)
  req = Net::HTTP::Get.new(uri)
  http = Net::HTTP.new(uri.hostname, uri.port)
  resp = http.request(req)
  resp.body
end

get '/' do
	data = read_from_interwebs('http://api.gojimo.net/api/v4/qualifications')
	@quals = JSON.parse(data)
	erb :home
end

