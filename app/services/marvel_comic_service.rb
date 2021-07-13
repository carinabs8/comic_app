class MarvelComicService
  attr_reader :ts
  include FaradayModule

  def comics(params={})
    page =  params[:page]&.to_i || 1
    character_ids = params['character_ids']
    Rails.cache.fetch(comics_cache_name(page, character_ids), expires_in: 24.hours) do

      response = conn.get(comics_path) do |request|
        request.params = comics_params(page: page, character_ids: character_ids)
      end

      {
        body: response_body(response), status: response_status(response)
      }
    end
  end

  def comic_characters(name: nil)
    response = conn.get(comic_characters_path) do |request|
      request.params = comic_characters_params(name: name)
    end
    { body: response_body(response), status: response.status }
  end

  private

  def comics_cache_name(page, character_ids)
    ['comics', page, character_ids&.sort ].join('_')
  end

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

  def comics_params(page: 1, per_page: 20, character_ids:)
    offset = (page - 1) * per_page
    params = { orderBy: '-modified', offset: offset }
    unless character_ids.blank?
      params.merge!(characters: character_ids.join('-'))
    end

    default_params.merge(params)
  end

  def comic_characters_params(name:)
    return default_params if name.nil?
    default_params.merge({ name: name })
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

  def comic_characters_path
    "/v1/public/characters"
  end

  def default_domain
    Rails.application.credentials.fetch(:MARVEL_DOMAIN, '')
  end
end