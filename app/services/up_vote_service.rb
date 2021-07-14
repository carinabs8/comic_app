class UpVoteService
	attr_reader :comic_book_external_id, :http_status, :user_id

	def initialize(comic_book_external_id, user_id)
		@comic_book_external_id = comic_book_external_id
		@user_id = user_id
	end

	def vote!
		popular_comic = PopularComic.where(external_id: comic_book_external_id, user_id: user_id).first_or_initialize
		save_or_destroy_record!(popular_comic)
	end

	private

	def save_or_destroy_record!(record)
		if record.new_record?
			record.save!
			@http_status = 201
		else
			record.destroy!
			@http_status = 204
		end
	end
end
