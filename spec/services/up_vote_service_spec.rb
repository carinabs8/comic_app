# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpVoteService, type: :model do
	describe '#vote!' do
		it 'create new record' do
			upvote_service = UpVoteService.new(1, 1)
			expect{
				upvote_service.vote!
			}.to change{
				PopularComic.count
			}.by(1)
		end

		it 'returns http_status 201 on new vote' do
			upvote_service = UpVoteService.new(1, 1)
			upvote_service.vote!
			expect(upvote_service.http_status).to eq(201)
		end

		it 'destroy a vote when already exists' do
			create(:popular_comic)
			upvote_service = UpVoteService.new(1, 1)
			expect{
				upvote_service.vote!
			}.to change{
				PopularComic.count
			}.by(-1)
		end

		it 'returns http_status 204 on new vote' do
			create(:popular_comic)
			upvote_service = UpVoteService.new(1, 1)
			upvote_service.vote!
			expect(upvote_service.http_status).to eq(204)
		end
	end
end