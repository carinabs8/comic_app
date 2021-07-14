class BookCoversController < ApplicationController
  def index
    marvel_service = MarvelComicService.new
    response = marvel_service.comics(comics_params)
    pagination(response[:body]['data'], params)
    render json: response[:body].to_json, status: response[:status]
  end

  def search
    marvel_service = MarvelComicService.new
    response = marvel_service.comic_characters(name: comics_params[:name])

    response = marvel_service.comics(params.merge(character_ids(response[:body]['data'])))
    pagination(response[:body]['data'], params)
    render json: response[:body].to_json, status: response[:status]
  end

  private

  def comics_params
    return params if params[:name].blank?
    { name: params[:name] }.to_options
  end

  def character_ids(data)
    return {} if data.blank?
    { character_ids: data['results']&.map{|result| result['id']} }
  end

  def pagination(data, params)
    return {} if data.blank?
    data.merge!(PaginateService.paginate(params, data))
  end
end
