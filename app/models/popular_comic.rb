class PopularComic < ApplicationRecord
  validates :external_id, :user_id, presence: true

  scope :user_favorite_comic, -> (user_id) { where(user_id: user_id) }
  before_commit :remove_cache

  class << self
    def favorites_by_user_id(user_id)
      Rails.cache.fetch(favorites_by_user_id_cache_name(user_id)) do
        user_favorite_comic(user_id).pluck(:external_id)
      end
    end

    def favorites_by_user_id_cache_name(user_id)
      ['favorites_by_user_id', user_id].join('_')
    end
  end

  private

  def remove_cache
     Rails.cache.clear
  end
end
