ENV['RACK_ENV'] = 'test'

require './gojimo-demo.rb'

require 'test/unit'
require 'rack/test'

class GojimoDemoTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

	def setup
	end


	# qual model tests

	def test_qual_created
		q = Qual.from_json('{"id":"123","subjects":[]}')
		assert q.instance_of?(Qual)
	end

	def test_qual_created_with_name
		q = Qual.from_json('{"id":"123","name":"foo","subjects":[]}')
		assert q.name == 'foo'
	end

	def test_qual_created_with_different_name
		q = Qual.from_json('{"id":"123","name":"bar","subjects":[]}')
		assert q.name == 'bar'
	end

	def test_qual_can_derive_gid_from_id
		q = Qual.from_json('{"id":"123","subjects":[]}')
		assert q.gid == '123'
	end

	def test_qual_can_derive_updated_at
		n1 = DateTime.now
		q = Qual.from_json('{"id":"123","subjects":[]}')
		n2 = DateTime.now
		assert q.updated_at >= n1
		assert q.updated_at <= n2
	end

	def test_quals_persisted
		q = Qual.from_json('{"id":"123","subjects":[]}')
		assert q.saved?
	end

	# subj model tests

	def test_subj_can_derive_gid_from_id
		s = Subj.update_or_create('id' => '123')
		assert s.gid == '123'
	end

	def test_subj_can_derive_updated_at
		n1 = DateTime.now
		s = Subj.update_or_create('id' => '123')
		n2 = DateTime.now
		assert s.updated_at >= n1
	end

	# data relationships

	def test_qual_has_subjects
		q = Qual.from_json('{"id":"123","subjects":[{"id":"123"}]}')
		assert q.subjs.length == 1
		assert q.subjs.first.qual == q
		assert q.subjs.first.saved?
	end

	def test_qual_has_multiple_subjects
		q = Qual.from_json('{"id":"123","subjects":[{"id":"123"},{"id":"124"}]}')
		assert q.subjs.length == 2
		assert q.subjs.last.qual == q
	end

	# multiple qualifications

	def test_can_have_multiple_qualifications
		qq = Qual.from_json('[{"id":"123","subjects":[]},{"id":"134","subjects":[]}]')
		assert qq.length == 2
	end

	# webapp tests

  def test_basic_www
		get '/'
    assert last_response.ok?
  end

	def test_qual_h1s_created
		Qual.all.destroy!
		Subj.all.destroy!

		Qual.from_json('[{"id":"123","name":"foo","subjects":[]}]')

		get('/')
		assert last_response.body.include?('<h1>foo</h1>')
	end

	def test_app_reads_from_feed_in_absence_of_data
		Qual.all.destroy!
		Subj.all.destroy!
		get('/')
		assert last_response.body.include?('<h1>')
	end

	def test_subj_divs_created
		Qual.all.destroy!
		Subj.all.destroy!

		Qual.from_json('[{"id":"123","name":"foo","subjects":[{"id":"123","title":"bar"}]}]')

		get('/')
		assert last_response.body.include?('<div>bar</div>')
	end

	def test_subj_coloured_correctly
		Qual.all.destroy!
		Subj.all.destroy!

		Qual.from_json('[{"id":"123","name":"foo","subjects":[{"id":"123","colour":"puce"}]}]')

		get('/')
		assert last_response.body.include?('<div style="background-color:puce"></div>')
	end

end