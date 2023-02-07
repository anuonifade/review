# frozen_string_literal: true

require "rails_helper"

describe Api::V1::ReviewsController do
  let!(:user_new) {create(:user)}
  let(:private_key) { OpenSSL::PKey::RSA.new 2048 }
  let(:public_key) { private_key.public_key }
  let(:restaurant) { create(:restaurant) }
  let(:validtoken) do
    binding.pry
    payload = { user_id: user_new.id }
    JsonWebToken.encode(payload:, rsa_key: OpenSSL::PKey::RSA.new(private_key))
  end

  before do
    stub_const("ENV", ENV.to_hash.merge("rsa_private_key" => private_key.to_s))
    stub_const("ENV", ENV.to_hash.merge("rsa_public_key" => public_key.to_s))
  end
  
  xdescribe "#create" do
    subject(:create) { post :create, params: params }
    let(:reviews) { { description: 'First review', user: user, restaurant: restaurant, rating: 4.2 } }

    context "with valid user and valid review params" do
      it "creates a valid review" do
        request.headers["Authorization"] = "Bearer #{validtoken}"
        
        create

        expect(response).to have_http_status(201)
        expect(JSON.parse(response.body)["user"]["email"]).to eq(user.email)
      end
    end
  end

  describe '#index' do
    subject(:reviews) { get :index }
    subject(:reviews_by_date) { get :index }
    subject(:review_by_restaurant) { get :index }
    subject(:review_by_user) { get :index }

    let(:user1) {create(:user, first_name: "Abc", last_name: "Xyz", email: "abcxyz@mail.com")}
    let(:user2) {create(:user, first_name: "Abc1", last_name: "Xyz1", email: "abcxyz1@mail.com")}
    
    let(:restaurant1) {create(:restaurant, name: 'Restaurant 1', address: 'Address 1', description: 'Description 1')}
    let(:restaurant2) {create(:restaurant, name: 'Restaurant 2', address: 'Address 2', description: 'Description 2')}
    
    let!(:review1) { create(:review, description: 'Review Description 1', user: user1, restaurant: restaurant1)}
    let!(:review2) { create(:review, description: 'Review Description 2', user: user1, restaurant: restaurant2)}
    let!(:review3) { create(:review, description: 'Review Description 3', user: user1)}
    let!(:review4) { create(:review, description: 'Review Description 4', user: user2, restaurant: restaurant1)}
    let!(:review5) { create(:review, description: 'Review Description 5', user: user2, restaurant: restaurant2)}

    let(:private_key) { OpenSSL::PKey::RSA.new 2048 }
    let(:public_key) { private_key.public_key }
    let(:validtoken) do
      payload = { user_id: user1.id }
      JsonWebToken.encode(payload:, rsa_key: OpenSSL::PKey::RSA.new(private_key))
    end

    before do
      stub_const("ENV", ENV.to_hash.merge("rsa_private_key" => private_key.to_s))
      stub_const("ENV", ENV.to_hash.merge("rsa_public_key" => public_key.to_s))
    end

    context "when no search_type and search_value is set" do
      context "and not sort value is set" do
        it "fetches all reviews and sort by date DESC" do
          request.headers["Authorization"] = "Bearer #{validtoken}"

          reviews

          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body)).not_to be_nil
        end
      end
    end

    context "when search_type and search_value is set" do
      context "when search_type is by_date" do
        it "return all the review for that date" do
          request.headers["Authorization"] = "Bearer #{validtoken}"
          request.query_string = "search_type=by_date&search_value=#{review1.created_at}"

          reviews_by_date

          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body).count).to eq(5)
        end
      end

      context "when search_type is by_user and the search_value is set" do
        it "returns all the review for that user" do
          request.headers["Authorization"] = "Bearer #{validtoken}"
          request.query_string = "search_type=by_user&search_value=#{user1.email}"

          review_by_user

          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body).count).to eq(3)
        end
      end

      context "when search_type is by_restaurant and the search_value is set" do
        it "returns all the review for that restaurant" do
          request.headers["Authorization"] = "Bearer #{validtoken}"
          request.query_string = "search_type=by_restaurant&search_value=#{restaurant1.name}"

          review_by_restaurant

          expect(response).to have_http_status(200)
          expect(JSON.parse(response.body).count).to eq(2)
        end
      end
    end
  end
end
