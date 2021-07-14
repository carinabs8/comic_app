class CreatePopularComics < ActiveRecord::Migration[6.1]
  def change
    create_table :popular_comics do |t|
      t.bigint :external_id, index: true, null: false
      t.bigint :user_id, index: true, null: false

      t.timestamps
    end

    add_index :popular_comics, [:external_id, :user_id]
  end
end
