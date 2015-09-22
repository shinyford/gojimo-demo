
class Qual
  include DataMapper::Resource

	property :id,       	Serial
  property :name,				String, :length => 200
  property :gid,				String, :length => 200
  property :country,		String, :length => 200
	property :updated_at,	DateTime

	has n, :subjs, :through => Resource

	GOJIMOFEED = 'http://api.gojimo.net/api/v4/qualifications'

	def update_attrs(attrs)

		attrs['subjs'] = []
		attrs.delete('subjects').each do |subj|
			attrs['subjs'] << Subj.update_or_create(subj)
		end

		attrs['gid'] = attrs.delete('id')
		attrs['country'] = attrs['country']['name'] if attrs['country']
		attrs['updated_at'] = DateTime.now

		attrs.each do |k,v|
			k += '='
			send(k, v) if respond_to?(k)
		end
	end

	def full_name
		@full_name ||= country.blank? ? name : "#{name} (#{country})"
	end

	def subjects
		@subjects ||= subjs.sort
	end

	class << self

		def update_or_create(attrs)
			q = first_or_create(:gid => attrs['id'])
			q.update_attrs(attrs)
			q.save # puts ">>> #{q.name}: #{q.save} #{q.dirty?}"
			q
		end

		def from_json(json)
			data = JSON::parse(json)
			if data.instance_of?(Array)
				data.collect { |qattrs| update_or_create(qattrs) }
			else
				update_or_create(data)
			end
		end

		def fetch_all
			if all.size == 0
			  uri = URI.parse(GOJIMOFEED)
			  req = Net::HTTP::Get.new(uri)
			  http = Net::HTTP.new(uri.hostname, uri.port)
			  resp = http.request(req)
			  from_json(resp.body)
			else
				all
			end.reject { |q| q.subjs.length == 0 }
		end

	end

end