module ResponseExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { message: e.message }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { message: e.message }, status: :unprocessable_entity
    end

    rescue_from JWT::DecodeError do |e|
      render json: { message: "Unable log you in. Try again or log in" }, status: :unauthorized
    end

    rescue_from JWT::ExpiredSignature do |e|
      render json: { message: "You session has ended, log in again" }, status: :unauthorized
    end
  end
end