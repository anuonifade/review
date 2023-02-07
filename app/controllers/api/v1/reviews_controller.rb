module Api
  module V1
    class ReviewsController < ApplicationController
      before_action :current_user
      before_action :search_params, only: :index
      before_action :set_review, only: %i[update destroy]

      def create
        review = Review.create!(review_params.merge(user_id: @current_user.id))

        render json: review, status: :created
      end

      def update
        @review.update!(review_params)
        head :no_content
      end

      def index
        sort_type = search_params[:sort_type].freeze || "DESC".freeze
        review =  Review.all.order("created_at #{sort_type}")
        
        return render json: Review.all.to_json({ include: [:user, :restaurant] }), only: [:description, :rating, :created_at], status: :ok unless search_params[:search_type].present?

        result = review.send(search_params[:search_type].to_sym, search_params[:search_value], sort_type)
        render json: result.to_json({ include: [:user, :restaurant] }), only: [:description, :rating, :created_at], status: :ok
      end

      def destroy
        @review.destroy!
        head :no_content
      end

      private

      def review_params
        params.permit(:restaurant_id, :rating, :description)
      end

      def search_params
        request.query_parameters
      end

      def set_review
        review_id = params[:id]
        @review = Review.find_by!(id: review_id)
      end
    end
  end
end