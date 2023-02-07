class ModifyReviewTable < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :rating, :float
    remove_column :reviews, :reviewed_at, :datetime
  end
end
