module Api
  module V1
    class SessionsController < ApplicationController
      before_action :current_user, only: :index

      def create
        user = User.create!(user_params)
        render json: user, only: [:first_name, :last_name, :email], status: :created
      end

      def index
        render json: User.find_by!(id: current_user.id).to_json({ include: [:reviews]}), status: :ok
      end

      def signin
        user = User.find_by!(email: signin_params[:email])
        if user && user.authenticate(signin_params[:password])
          render json: auth_token(user), status: :ok
        else
          render json: {message: "Unauthorized"}, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(:first_name, :last_name, :email, :password)
      end

      def signin_params
        params.permit(:email, :password)
      end

      def auth_token(user)
        {
          token: JsonWebToken.encode(payload: {user_id: user.id }, rsa_key: ENV["rsa_private_key"])
        }
      end
    end
  end
end
