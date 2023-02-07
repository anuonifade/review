class CreateReview < ActiveRecord::Migration[6.1]
  def change
    create_table :reviews do |t|
      t.string :description
      t.datetime :reviewed_at

      t.timestamps
    end
  end
end
