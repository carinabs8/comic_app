require 'rails_helper'

RSpec.describe "BookCovers", type: :request do
  let(:comics_response) do
    {
      "code"=>200,
     "status"=>"Ok",
     "copyright"=>"© 2021 MARVEL",
     "attributionText"=>"Data provided by Marvel. © 2021 MARVEL",
     "attributionHTML"=>"<a href=\"http://marvel.com\">Data provided by Marvel. © 2021 MARVEL</a>",
     "etag"=>"c4eecbbfb9edaa924b0bec9f559ba85e3f2c7e4f",
     "data"=>{
        "offset"=>0,
        "limit"=>20,
        "total"=>49265,
        "count"=>20,
        "results"=> [
          {
            "id"=>91806,
            "digitalId"=>0,
            "title"=>"KING IN BLACK: PLANET OF THE SYMBIOTES TPB (Trade Paperback)",
            "issueNumber"=>1,
            "variantDescription"=>"",
            "description"=>nil,
            "modified"=>"2021-03-25T09:26:40-0400",
            "isbn"=>"978-1-302-92810-0",
            "upc"=>"",
            "diamondCode"=>"APR210986",
            "ean"=>"9781302 928100 51599",
            "issn"=>"",
            "format"=>"Trade Paperback",
            "pageCount"=>112,
            "textObjects"=>[],
            "resourceURI"=>"http://gateway.marvel.com/v1/public/comics/91806",
            "urls"=> [
              {
                "type"=>"detail",
                "url"=>
                "http://marvel.com/comics/collection/91806/king_in_black_planet_of_the_symbiotes_tpb_trade_paperback?utm_campaign=apiRef&utm_source=07e3e205bebd46de31d15ee9a76d85c2"
              }
            ],
          "variants"=>[],
          "collections"=>[],
          "collectedIssues"=>[],
          "dates"=>[{"type"=>"onsaleDate", "date"=>"2021-07-14T00:00:00-0400"}, {"type"=>"focDate", "date"=>"2021-05-17T00:00:00-0400"}],
          "prices"=>[{"type"=>"printPrice", "price"=>15.99}],
          "thumbnail"=>{"path"=>"http://i.annihil.us/u/prod/marvel/i/mg/5/b0/60a2e0406cf72", "extension"=>"jpg"},
          "images"=>[{"path"=>"http://i.annihil.us/u/prod/marvel/i/mg/5/b0/60a2e0406cf72", "extension"=>"jpg"}],
          "creators"=>
            {
              "available"=>19,
              "collectionURI"=>"http://gateway.marvel.com/v1/public/comics/91806/creators",
              "items"=>
                [
                  {
                    "resourceURI"=>"http://gateway.marvel.com/v1/public/creators/13162", "name"=>"Erick Arciniega", "role"=>"colorist"
                  }
                ],
              "returned"=>19
            },
          "characters"=>{
            "available"=>0, "collectionURI"=>"http://gateway.marvel.com/v1/public/comics/91806/characters", "items"=>[], "returned"=>0
          },
          "stories"=>{
            "available"=>2,
            "collectionURI"=>"http://gateway.marvel.com/v1/public/comics/91806/stories",
            "items"=>[
              {
                "resourceURI"=>"http://gateway.marvel.com/v1/public/stories/204697", "name"=>"cover from KING IN BLACK: PLANET OF THE SYMBIOTES TPB (2021) #1", "type"=>"cover"
              }
            ],
            "returned"=>2
          },
          "events"=>{
            "available"=>0, "collectionURI"=>"http://gateway.marvel.com/v1/public/comics/91806/events", "items"=>[], "returned"=>0}
          }
        ]
      }
    }.to_json
  end

  describe "GET /index" do
    let(:conn)   { Faraday.new { |b| b.adapter(:test, @stubs) } }
    let(:client) { MarvelComicService.new }
    let(:invalid_credentials) do
      {
        "code": "InvalidCredentials",
        "message": "The passed API key is invalid."
      }.to_json
    end

    it 'Returns 200 ok' do
      @stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/v1/public/comics?orderBy=-modified') { |env| [ 200, {}, comics_response ] }
      end

      allow_any_instance_of(MarvelComicService).to receive(:connection).and_return(conn)

      get book_covers_path
      expect(response.status).to eq(200)
    end

    it 'Returns 403 when token is invalid' do
      @stubs =  Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/v1/public/comics') { |env| [ 403, {}, invalid_credentials ] }
      end

      allow_any_instance_of(MarvelComicService).to receive(:connection).and_return(conn)

      get book_covers_path
      expect(response.status).to eq(403)
    end
  end

  describe 'POST /search' do
    let(:stubs) do
      Faraday::Adapter::Test::Stubs.new
    end

    let(:conn) do
      Faraday.new { |b| b.adapter(:test, stubs) }
    end

    let(:character_response) do
      {
       "code"=>200,
       "data"=>{
          "offset"=>0,
          "limit"=>20,
          "total"=>49265,
          "count"=>20,
          "results"=> [
            'id' => 1,
            'name' => 'THOR'
          ]
        }
      }
    end

    it 'Returns comics books by character named Thor' do
      stubs.get('/v1/public/characters') { |env| [ 200, {'Content-Type' => 'application/json'}, character_response.to_json ] }
      stubs.get('/v1/public/comics') { |env| [ 200, {'Content-Type' => 'application/json'}, comics_response ] }
      allow_any_instance_of(MarvelComicService).to receive(:connection).and_return(conn)

      post search_book_covers_path, params: {name: 'THOR'}
      expect(response.status).to eq(200)
    end

    it 'Return 200 ok when character is not pass under seach parameter' do
      stubs.get('/v1/public/comics') { |env| [ 200, {'Content-Type' => 'application/json'}, {}.to_json ] }
      allow_any_instance_of(MarvelComicService).to receive(:connection).and_return(conn)

      post search_book_covers_path
      expect(response.status).to eq(200)
    end
  end
end
