class Restaurant < ApplicationRecord
  has_many :reviews, dependent: :destroy
  has_many :users, through: :review
end