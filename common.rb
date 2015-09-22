
require 'net/http'
require 'json'
require 'dm-core'
require 'dm-migrations'
require 'dm-validations'

GOJIMODEMO_DB = "#{Dir.pwd}/db-gojimo-demo.sqlite3"

DataMapper.setup(:default, 'sqlite3://' + GOJIMODEMO_DB)
require './models/qual'
require './models/subj'
DataMapper.auto_upgrade!

def nil.blank?
	true
end

class String
	def blank?
		self == ''
	end
end

