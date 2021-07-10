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
    it "make a request to comics with '/v1/public/comics/1/characters' path" do
      stubs.get('/v1/public/comics/1/characters') { |env| [ 200, {'Content-Type' => 'application/json'}, {}.to_json ] }
      allow_any_instance_of(described_class).to receive(:connection).and_return(conn)

      marvel_comic_service = described_class.new
      expect(marvel_comic_service.comic_characters(comic_id: 1)).to eq({ body: {}, status: 200 })
    end

    it 'searches by character' do
      stubs.get('/v1/public/comics/1/characters') { |env| [ 200, {'Content-Type' => 'application/json'}, {}.to_json ] }
      allow_any_instance_of(described_class).to receive(:connection).and_return(conn)

      marvel_comic_service = described_class.new
      expect(marvel_comic_service).to receive(:comic_characters_params).with(nameStartsWith: 'X-men').and_return({ nameStartsWith: 'X-men' })
      marvel_comic_service.comic_characters(comic_id: 1, nameStartsWith: 'X-men')
    end
  end
end
