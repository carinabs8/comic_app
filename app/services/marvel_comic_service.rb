class MarvelComicService
	attr_reader :default_params, :ts
	include FaradayModule

	def comics
		conn.get(comics_path)
	end

	private

	def default_params
		@ts = Time.current.to_i.to_s
    @default_params ||= { 
    	ts: ts,
    	hash: marvel_hash,
    	apikey: Rails.application.credentials.fetch(:MARVEL_PUBLIC_KEY, '')
    }
  end

  def marvel_hash
  	Digest::MD5.hexdigest(
	  	ts +
	  	Rails.application.credentials.fetch(:MARVEL_PRIVATE_KEY, '') +
	  	Rails.application.credentials.fetch(:MARVEL_PUBLIC_KEY, '')
  	)
  end

  def comics_path
  	'/v1/public/comics?orderBy=-modified'
  end

  def default_domain
    Rails.application.credentials.fetch(:MARVEL_DOMAIN, '')
  end
end