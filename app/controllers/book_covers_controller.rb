class BookCoversController < ApplicationController
  def index
    marvel_service = MarvelComicService.new
    response = marvel_service.comics
    render json: response[:body].to_json, status: response[:status]
  end
end
