class MarvelComicService
  attr_reader :ts
  include FaradayModule

  def comics
    response = conn.get(comics_path) do |request|
      request.params = comics_params
    end

    {
      body: response_body(response), status: response_status(response)
    }
  end

  def comic_characters(comic_id:, nameStartsWith: nil)
    response = conn.get(comic_characters_path(comic_id)) do |request|
      request.params = comic_characters_params(nameStartsWith: nameStartsWith)
    end
    { body: response_body(response), status: response.status }
  end

  private

  def response_body(response)
    return if response.body.nil?
    JSON.parse(response.body)
  end

  def response_status(response)
    response.status
  end

  def default_params
    @ts = Time.current.to_i.to_s
    @default_params ||= { 
      ts: ts,
      hash: marvel_hash,
      apikey: Rails.application.credentials.fetch(:MARVEL_PUBLIC_KEY, '')
    }
  end

  def comics_params
    default_params.merge({ orderBy: '-modified' })
  end

  def comic_characters_params(nameStartsWith:)
    return default_params if nameStartsWith.nil?
    default_params.merge({ nameStartsWith: nameStartsWith })
  end

  def marvel_hash
    Digest::MD5.hexdigest(
      ts +
      Rails.application.credentials.fetch(:MARVEL_PRIVATE_KEY, '') +
      Rails.application.credentials.fetch(:MARVEL_PUBLIC_KEY, '')
    )
  end

  def comics_path
    '/v1/public/comics'
  end

  def comic_characters_path(comic_id)
    "/v1/public/comics/#{comic_id}/characters"
  end

  def default_domain
    Rails.application.credentials.fetch(:MARVEL_DOMAIN, '')
  end
end