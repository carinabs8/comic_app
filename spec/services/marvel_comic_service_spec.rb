# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarvelComicService, type: :model do
  it 'receives urls default params' do
    expect(Faraday).to receive(:new).with({
      url: 'http://gateway.marvel.com',
      params: {
        ts: '1625108400',
        apikey: 'xxx',
        hash: '05fbc354907e7b014a81fb74e856f213'
      },
      headers: {'Content-Type' => 'application/json'}
    })

    travel_to Time.local(2021,7,1,0,0) do
      marvel_comic_service = described_class.new
    end
  end

  let(:stubs) do
    Faraday::Adapter::Test::Stubs.new
  end

  let(:conn) do
    Faraday.new { |b| b.adapter(:test, stubs) }
  end

  describe '#comics' do
    it "make a request to comics with '/v1/public/comics' path" do
      stubs.get('/v1/public/comics') { |env| [ 200, {'Content-Type' => 'application/json'}, {}.to_json ] }

      allow_any_instance_of(described_class).to receive(:connection).and_return(conn)

      marvel_comic_service = described_class.new
      expect(marvel_comic_service.comics).to eq({ body: {}, status: 200 })
    end
  end

  describe '#comic_characters' do
    let(:character_payload) do
      {
       "code"=>200,
       "data"=>{
          "offset"=>0,
          "limit"=>20,
          "total"=>49265,
          "count"=>20,
          "results"=> [
            'id' => 1,
            'name' => 'X-men'
          ]
        }
      }
    end

    it "searches by character's name" do
      stubs.get('/v1/public/characters') { |env| [ 200, {'Content-Type' => 'application/json'}, character_payload.to_json ] }
      allow_any_instance_of(described_class).to receive(:connection).and_return(conn)

      marvel_comic_service = described_class.new
      expect(marvel_comic_service.comic_characters(name: 'X-men')).to eq({
        :body=>{
          "code"=>200, 
          "data"=>{
            "offset"=>0, "limit"=>20, "total"=>49265, "count"=>20, 
            "results"=>[{"id"=>1, "name"=>"X-men"}]
          }
        },
        :status=>200
      })
    end

    it 'not found record when name is blank' do
      marvel_comic_service = described_class.new
      expect(marvel_comic_service.comic_characters).to eq({
        :body=>{ 
          "data"=>{ 
            'results'=> [],
            'total'=> 0
          }
        },
        :status=>200
      })
    end
  end
end
