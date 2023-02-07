class ApplicationController < ActionController::API
  include ResponseExceptionHandler

  def current_user
    valid_token = validate_token(request)
    return unless valid_token.present? && valid_token["user_id"].present?

    @current_user = User.find_by!(id: valid_token["user_id"])

    return render json: { message: "You session has ended, log in again" }, status: :unauthorized unless @current_user.present?
  end

  private

  def validate_token(request)
    auth_headers = auth_headers(request)
    return unless auth_headers.present?
    JsonWebToken.decode(token: auth_headers[1], verify: true, rsa_key: ENV["rsa_public_key"])
  end

  def auth_headers(request)
    request.headers["authorization"]&.split(" ")
  end
end
