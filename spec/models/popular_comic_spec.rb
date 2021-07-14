require 'rails_helper'

RSpec.describe PopularComic, type: :model do
  describe 'validations' do
    %w(external_id user_id).each do |attribute|
      it 'Cannot be blank' do
        popular_comic = described_class.new({attribute.to_s => nil})
        popular_comic.valid?
        expect(popular_comic.errors[attribute]).to eq(["can't be blank"])
      end
    end
  end

  describe '#favorites_by_user_id' do
    it 'returns all external_id from some user_id' do
      (1..3).each{|i| create(:popular_comic, external_id: i, user_id: 1)}
      expect(PopularComic.favorites_by_user_id(1)).to eq([1,2,3])
    end
  end
end
