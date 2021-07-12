class BookCoversController < ApplicationController
  def index
    marvel_service = MarvelComicService.new
    response = marvel_service.comics(params)
    data = response[:body]['data']
    data.merge!(PaginateService.paginate(params, data))
    render json: response[:body].to_json, status: response[:status]
  end

  def search
    marvel_service = MarvelComicService.new
    response = marvel_service.comic_characters(name: params[:name])
    data = response[:body]['data']
    data.merge!(PaginateService.paginate(params, data))
    render json: response[:body].to_json, status: response[:status]
  end
end
