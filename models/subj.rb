require 'json'

class Subj
  include DataMapper::Resource

	property :id,       	Serial
  property :title,			String, :length => 200
  property :gid,				String, :length => 200
  property :colour,			String
	property :updated_at,	DateTime

	has n, :quals, :through => Resource

	def update_attrs(attrs)
		attrs['gid'] = attrs.delete('id')
		attrs['updated_at'] = DateTime.now
		attrs.each do |k,v|
			k += '='
			send(k, v) if respond_to?(k)
		end
	end

	def <=>(other)
		self.title <=> other.title
	end

	class << self

		def update_or_create(attrs)
			s = first_or_create(:gid => attrs['id'])
			s.update_attrs(attrs)
			s.save
			s
		end

	end

end