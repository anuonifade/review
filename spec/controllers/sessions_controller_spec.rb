# frozen_string_literal: true

require "rails_helper"

describe Api::V1::SessionsController do
  describe "#create" do
    subject(:create) { post :create, params: params }
    subject(:invalid_create) { post :create, params: invalid_params }
    let(:params) { { first_name: 'John', last_name: 'Doe', email: 'johndoe@doe.com', password: 'abc123' } }
    let(:invalid_params) { { first_name: "John" } }

    context "with valid user params" do
      it "creates a valid user" do
        create

        expect(response).to have_http_status(201)
        expect(JSON.parse(response.body)["first_name"]).to eq('John')
      end
    end

    context "without a valid user params" do
      it "returns a 422 with wrong user" do
        invalid_create
        expect(response).to have_http_status(422)
      end
    end
  end

  describe '#signin' do
    subject(:signin) { post :signin, params: signin_params}
    subject(:invalid_signin) { post :signin, params: invalid_signin_params}
    subject(:invalid_signin_wrong_password) { post :signin, params: invalid_signin_params2}
    let(:signin_params) {{ email: user.email, password: 'abc123'}}
    let(:invalid_signin_params) {{ email: 'wrongemail@email.com', password: '123' }}
    let(:invalid_signin_params2) {{ email: user.email, password: 'a123' }}
    let!(:user) { create(:user, first_name: 'Jane', last_name: 'Doe', email: 'janedoe@doe.com', password: 'abc123') }
    let(:private_key) { OpenSSL::PKey::RSA.new 2048 }
    let(:public_key) { private_key.public_key }

    before do
      stub_const("ENV", ENV.to_hash.merge("rsa_private_key" => private_key.to_s))
      stub_const("ENV", ENV.to_hash.merge("rsa_public_key" => public_key.to_s))
    end

    context 'with a valid params' do
      it 'returns a valid token' do
        signin
        
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['token']).not_to be_nil
      end
    end

    context 'with an invalid params' do
      it 'returns not found for non existing email' do
        invalid_signin

        expect(response).to have_http_status(404)
      end

      it 'returns unauthorized for wrong password' do
        invalid_signin_wrong_password

        expect(response).to have_http_status(401)
      end
    end
  end
end
