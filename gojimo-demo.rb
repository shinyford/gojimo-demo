#! /usr/bin/env ruby

require 'net/http'
require 'rubygems'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'
require 'sinatra'

GOJIMODEMO_DB = "#{Dir.pwd}/db-gojimo-demo.sqlite3"

DataMapper.setup(:default, 'sqlite3://' + GOJIMODEMO_DB)
require './models/qual.rb'
require './models/subj.rb'
DataMapper.auto_upgrade!

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

get '/' do
	@quals = Qual.fetch_all
	erb :home
end

