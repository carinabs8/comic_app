class MarvelComicService
  attr_reader :ts
  include FaradayModule

  def comics(params={}, user_id)
    page =  params[:page]&.to_i || 1
    character_ids = params['character_ids']
    Rails.cache.fetch(comics_cache_name(page, character_ids), expires_in: 24.hours) do

      response = conn.get(comics_path) do |request|
        request.params = comics_params(page: page, character_ids: character_ids)
      end
      body = inject_upvote_into_response(user_id, response_body(response))
      {
        body: body, status: response_status(response)
      }
    end
  end

  def comic_characters(name: nil)
    return no_data_found if name.blank?
    params = comic_characters_params(name: name)

    Rails.cache.fetch(comic_characters_cache_name(params), expires_in: 24.hours) do
      response = conn.get(comic_characters_path) do |request|
        request.params = params
      end
      { body: response_body(response), status: response.status }
    end
  end

  def inject_upvote_into_response(user_id, response)
    response_results(response).each do |result|
      if result.is_a?(Hash)
        result['user_favorite'] = PopularComic.favorites_by_user_id(user_id).include? result['id']&.to_i
      end
    end
    response
  end

  class << self
    def comics_cache_name(page:1, character_ids:[])
      [comics_path, page, character_ids&.sort ].join('_')
    end

    def comics_path
      '/v1/public/comics'
    end
  end

  private

  def response_results(response)
    return response if response['data'].blank?
    response['data']['results']
  end

  def no_data_found
    { 
      body: { 'data' => { 'results'=> [], 'total' => 0 }},
      status: 200
    }
  end

  def comics_cache_name(page, character_ids)
    MarvelComicService.comics_cache_name(page: page, character_ids: character_ids)
  end

  def comics_path
    MarvelComicService.comics_path
  end

  def comic_characters_cache_name(params)
    [comic_characters_path, params.values&.join('_')].join('_')
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

  def comic_characters_path
    "/v1/public/characters"
  end

  def default_domain
    Rails.application.credentials.fetch(:MARVEL_DOMAIN, '')
  end
end