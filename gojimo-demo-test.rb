ENV['RACK_ENV'] = 'test'

require './gojimo-demo'

require 'test/unit'
require 'rack/test'

class GojimoDemoTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

	def setup
		Qual.all.destroy!
		Subj.all.destroy!
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

	def test_qual_gets_country
		q = Qual.from_json('{"id":"123","name":"English","country":{"name":"United Kingdom"},"subjects":[]}')
		assert q.country == 'United Kingdom'
		assert q.full_name == 'English (United Kingdom)'
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

	def test_subjs_are_returned_in_alpha_order
		q = Qual.from_json('{"id":"123","subjects":[{"id":"123","title":"mmm"},{"id":"124","title":"ccc"},{"id":"125","title":"ddd"}]}')
		ss = q.subjects
		assert_equal '124', ss[0].gid
		assert_equal '125', ss[1].gid
		assert_equal '123', ss[2].gid
	end

	# data relationships

	def test_qual_has_subjects
		q = Qual.from_json('{"id":"123","subjects":[{"id":"123"}]}')
		assert_equal 1, q.subjs.length
		assert q.subjs.first.quals.include?(q)
		assert q.subjs.first.saved?
	end

	def test_qual_has_multiple_subjects
		q = Qual.from_json('{"id":"123","subjects":[{"id":"123"},{"id":"124"}]}')
		assert_equal 2, q.subjs.length
		assert q.subjs.last.quals.include?(q)
	end

	# multiple qualifications

	def test_can_have_multiple_qualifications
		qq = Qual.from_json('[{"id":"123","subjects":[]},{"id":"134","subjects":[]}]')
		assert_equal 2, qq.length
	end

	def test_only_quals_with_subjs
		Qual.from_json('[{"id":"123","subjects":[]},{"id":"134","subjects":[{"id":"100"}]}]')

		assert_equal 2, Qual.all.length
		assert_equal 1, Qual.fetch_all.length
	end

	# webapp tests

  def test_basic_www
		get '/'
    assert last_response.ok?
  end

	def test_qual_h2s_created
		Qual.from_json('[{"id":"123","name":"foo","subjects":[{"id":"100"}]}]')
		get('/')
		assert last_response.body.include?('<h2 id="123">foo</h2>')
	end

	def test_app_reads_from_feed_in_absence_of_data
		get('/')
		assert last_response.body.include?('<h2 id="')
	end

	def test_subj_lis_created
		Qual.from_json('[{"id":"123","name":"foo","subjects":[{"id":"123","title":"bar"}]}]')

		get('/')
		assert last_response.body.include?('<li>bar</li>')
	end

	def test_subj_coloured_correctly
		Qual.from_json('[{"id":"123","name":"foo","subjects":[{"id":"123","colour":"puce"}]}]')
		get('/')
		assert last_response.body.include?('<li style="background-color:puce"></li>')
	end

	def test_reset
		Qual.from_json('[{"id":"123","name":"foo","subjects":[{"id":"123","title":"bar"}]}]')
		assert_equal 1, Qual.all.length
		get('/')
		assert_equal 1, Qual.all.length
		get('/reset')
		get('/')
		assert Qual.all.length > 1
	end

end