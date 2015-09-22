require 'rubygems'
require 'sinatra'
require './common'

get '/' do
	@quals = Qual.fetch_all
	erb :home
end

get '/reset' do
	Qual.all.destroy!
	Subj.all.destroy!
	redirect '/'
end
