# frozen_string_literal: true
require "rails_helper"
require "openssl"

describe JsonWebToken do
  let(:payload) { { "data" => "data" } }
  let(:invalid_token) { { token: "thisisaninvalidtoken" } }
  let(:expiration) { 24.hours.from_now }
  let(:private_key) { OpenSSL::PKey::RSA.new 2048 }
  let(:public_key) { private_key.public_key }
  let(:invalid_rsa_key) { "thisisaninvalidrsakey" }
  let(:jwt_token) { nil }
  let(:invalid_jwt_token) { "thisisaninvaldjwttoken" }

  context "When a valid payload and keys" do
    let(:jwt_token) { JsonWebToken.encode(payload:, rsa_key: private_key) }

    it "creates a valid token" do
      expect { JsonWebToken.encode(payload:, rsa_key: private_key) }.not_to raise_error

      expect(jwt_token).not_to be_nil
    end

    it "verifies the token" do
      expect { JsonWebToken.decode(token: jwt_token, rsa_key: public_key) }.not_to raise_error

      decoded_token = JsonWebToken.decode(token: jwt_token, rsa_key: public_key)

      expect(decoded_token["data"]).to eq(payload["data"])
    end
  end

  context "When encoding with an invalid keys" do
    it "raises error for nil or invalid key" do
      expect { JsonWebToken.encode(payload:, rsa_key: invalid_rsa_key) }.to raise_error(/Neither PUB key nor PRIV key/)
    end
  end

  context "When decoding with an invalid token" do
    it "raises an invalid token error" do
      expect { JsonWebToken.decode(token: invalid_jwt_token, rsa_key: public_key) }.to raise_error(/Invalid JWT token/)
    end
  end

  context "When trying to use a public key to create jwt token" do
    it "raises private key is needed error" do
      expect { JsonWebToken.encode(payload:, rsa_key: public_key) }.to raise_error(/private key is needed/)
    end
  end

  context "When JWT token is expired" do
    let(:expiration) { Time.now - 24.hours }

    let(:expired_jwt_token) { JsonWebToken.encode(payload:, expiration:, rsa_key: private_key) }

    it "raises a expired token error" do
      expect { JsonWebToken.decode(token: expired_jwt_token, rsa_key: public_key) }.to raise_error(/Signature has expired/)
    end
  end
end
