class Review < ApplicationRecord
  belongs_to :user
  belongs_to :restaurant

  validates :rating, numericality: {only_integer: false, greater_than_or_equal_to: 1, less_than_or_equal_to: 5}

  scope :by_date, -> (date, sort_type) {
    where("created_at BETWEEN ? AND ?", date.to_datetime.beginning_of_day, date.to_datetime.end_of_day).order("created_at #{sort_type}")
  }

  scope :by_restaurant, -> (text, sort_type) {
    restaurant = Restaurant.where("name ILIKE ?", "%#{text}%").order("name #{sort_type}").pluck(:id)
    Review.where(restaurant: restaurant)
  }

  scope :by_user, -> (email, sort_type) {
    user = User.where("email = ?", email).order("email #{sort_type}").pluck(:id)
    Review.where(user: user)
  }
end
