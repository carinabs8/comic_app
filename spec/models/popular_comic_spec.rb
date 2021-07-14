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
end
