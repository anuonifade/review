class CreateRestaurant < ActiveRecord::Migration[6.1]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.text :address
      t.text :description

      t.timestamps
    end
  end
end
