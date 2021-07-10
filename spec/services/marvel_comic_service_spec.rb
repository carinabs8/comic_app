# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarvelComicService, type: :model do
  describe 'comics' do
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
        marvel_comic_service = MarvelComicService.new
      end
    end

    it "make a request to comics with '/v1/public/comics' path" do
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/v1/public/comics') { |env| [ 200, {'Content-Type' => 'application/json'}, {}.to_json ] }
      end
      conn = Faraday.new { |b| b.adapter(:test, stubs) }

      allow_any_instance_of(MarvelComicService).to receive(:connection).and_return(conn)

      marvel_comic_service = MarvelComicService.new
      expect(marvel_comic_service.comics).to eq({ body: {}, status: 200 })
    end
  end
end
