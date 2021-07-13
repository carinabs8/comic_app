class BookCoversController < ApplicationController
  def index
    marvel_service = MarvelComicService.new
    response = marvel_service.comics(comics_params)
    pagination(response[:body]['data'], params)
    render json: response[:body].to_json, status: response[:status]
  end

  def search
    marvel_service = MarvelComicService.new
    response = marvel_service.comic_characters(comics_params.to_options)

    data = response[:body]['data']
    params_character_ids = { character_ids: data['results']&.map{|result| result['id']} }
    response = marvel_service.comics(params.merge(params_character_ids))
    pagination(response[:body]['data'], params)
    render json: response[:body].to_json, status: response[:status]
  end

  private

  def comics_params
    return params unless params.has_key? :name
    { name: params[:name] }
  end

  def pagination(data, params)
    return {} if data.blank?
    data.merge!(PaginateService.paginate(params, data))
  end
end
