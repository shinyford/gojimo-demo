ENV['RACK_ENV'] = 'test'

require './gojimo-demo.rb'

require 'test/unit'
require 'rack/test'

TESTJSON = <<EOC
[
	{
		"id": "qual-01",
		"name": "Qualification 1",
		"subjects": [
			{
				"id": "subj Q1-1",
				"title": "Subject Q1-1",
				"link": "/api/v4/subjects/q1-1",
				"colour": "#FF0000"
			},
			{
				"id": "subj Q1-2",
				"title": "Subject Q1-2",
				"link": "/api/v4/subjects/q1-2",
				"colour": "#FFFF00"
			},
			{
				"id": "subj Q1-3",
				"title": "Subject Q1-3",
				"link": "/api/v4/subjects/q1-3",
				"colour": "#FF00FF"
			}
		],
		"default_products": [ ],
		"created_at": "2014-04-12T10:06:33.000Z",
		"updated_at": "2014-04-12T10:06:33.000Z",
		"link": "/api/v4/qualifications/q1"
	},
	{
		"id": "qual-02",
		"name": "Qualification 2",
		"subjects": [
			{
				"id": "subj Q2-1",
				"title": "Subject Q2-1",
				"link": "/api/v4/subjects/q2-1",
				"colour": "#FFFF00"
			},
			{
				"id": "subj Q2-2",
				"title": "Subject Q2-2",
				"link": "/api/v4/subjects/q2-2",
				"colour": "#00FF00"
			},
			{
				"id": "subj Q2-3",
				"title": "Subject Q2-3",
				"link": "/api/v4/subjects/q2-3",
				"colour": "#00FFFF"
			}
		],
		"default_products": [ ],
		"created_at": "2014-04-12T10:06:33.000Z",
		"updated_at": "2014-04-12T10:06:33.000Z",
		"link": "/api/v4/qualifications/q2"
	},
	{
		"id": "qual-03",
		"name": "Qualification 3",
		"subjects": [
			{
				"id": "subj Q3-1",
				"title": "Subject Q3-1",
				"link": "/api/v4/subjects/q3-1",
				"colour": "#FF00FF"
			},
			{
				"id": "subj Q3-2",
				"title": "Subject Q3-2",
				"link": "/api/v4/subjects/q3-2",
				"colour": "#00FFFF"
			},
			{
				"id": "subj Q3-3",
				"title": "Subject Q3-3",
				"link": "/api/v4/subjects/q3-3",
				"colour": "#0000FF"
			}
		],
		"default_products": [ ],
		"created_at": "2014-04-12T10:06:33.000Z",
		"updated_at": "2014-04-12T10:06:33.000Z",
		"link": "/api/v4/qualifications/q3"
	}
]
EOC

@thisjson = nil

# clumsy mocking
def setup_interwebs_response(resp)
	@@thisjson = resp
end
def read_from_interwebs(url)
	@@thisjson
end

class GojimoDemoTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

	def setup
		setup_interwebs_response(TESTJSON)
	end

	# webapp tests

  def test_basic_www
		get '/'
    assert last_response.ok?
  end

	def test_contains_q1
		get '/'
		assert last_response.body.include?('<h2>Qualification 1</h2>')
	end

	def test_contains_quals_from_json
		setup_interwebs_response('[{"name":"INTERLOPER","subjects":[]}]')
		get '/'
		assert last_response.body.include?('<h2>INTERLOPER</h2>')
	end

	def test_contains_all_quals_from_json
		setup_interwebs_response('[{"name":"INTERLOPER1","subjects":[]},{"name":"INTERLOPER2","subjects":[]}]')
		get '/'
		assert last_response.body.include?('<h2>INTERLOPER2</h2>')
		assert last_response.body.include?('<h2>INTERLOPER1</h2>')
	end

	def test_contains_subjects
		get '/'
		assert last_response.body.include?('<div>Subject Q1-1</div>')
	end

	def test_contains_appropriate_subjects
		get '/'
		assert last_response.body.include?('<div>Subject Q1-1</div>')
		assert last_response.body.include?('<div>Subject Q2-2</div>')
		assert last_response.body.include?('<div>Subject Q3-3</div>')
	end

end