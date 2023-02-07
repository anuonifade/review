# frozen_string_literal: true
require "jwt"
require "openssl"

class JsonWebToken
  attr_reader :rsa_key

  def self.encode(payload: {}, **options)
    # options:
    # expiration - defaults to 24 hours from now
    # aud - defaults to "app"
    # rsa_key - defaults to ENV["rsa_private_key"]
    rsa_key = options[:rsa_key] || ENV["rsa_private_key"]
    new(rsa_key).encode(payload, options)
  end

  def self.decode(token:, **options)
    # options:
    # rsa_key - defaults to ENV["rsa_public_key"]
    # verify - defaults to true
    rsa_key = options[:rsa_key] || ENV["rsa_public_key"]
    HashWithIndifferentAccess.new(new(rsa_key).decode(token, options))
  end

  def self.generate_access_token(login_session_id:, rsa_private_key:)
    expiration = ENV["ACCESS_TOKEN_EXP_IN_SEC"] || 15.minutes.from_now
    payload = { login_session_id: }

    encode(payload:, expiration:, rsa_key: rsa_private_key)
  end

  def initialize(rsa_key)
    rsa_key_instance = rsa_key.instance_of?(OpenSSL::PKey::RSA) ? rsa_key : OpenSSL::PKey::RSA.new(rsa_key)
    @rsa_key = rsa_key_instance
  end

  def encode(payload, options)
    payload["exp"] = (options[:expiration] || options[:exp] || 24.hours.from_now).to_i
    payload["aud"] = options[:aud] || "app"

    create_jwt(payload, rsa_key)
  end

  def decode(token, options)
    verify = options[:verify].nil? ? true : options[:verify]
    raise ArgumentError, "Invalid JWT token" if token.nil? || !(token =~ JWT_CHECK)

    decode_jwt(token, rsa_key, verify)[0]
  end

  private

  def create_jwt(payload, rsa_key)
    JWT.encode(payload, rsa_key, "RS256")
  end

  def decode_jwt(token, rsa_key, verify)
    JWT.decode(token, rsa_key, verify, { algorithm: "RS256" })
  end

  JWT_CHECK = /^[A-Za-z0-9\-_=]+\.[A-Za-z0-9\-_=]+\.?[A-Za-z0-9\-_.+\/=]*$/
end
