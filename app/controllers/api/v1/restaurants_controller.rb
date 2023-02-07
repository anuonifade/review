module Api
  module V1
    class RestaurantsController < ApplicationController

      def create
        restaurant = Restaurant.create!(restaurant_params)

        render json: restaurant, status: :created
      end

      def index
        render json: Restaurant.all.to_json({ include: [reviews: { include: :user }] }), only: [:name, :description, :address], status: :ok
      end

      private

      def restaurant_params
        params.permit(:name, :address, :description)
      end
    end
  end
end
