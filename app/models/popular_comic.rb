class PopularComic < ApplicationRecord
	validates :external_id, :user_id, presence: true
end
