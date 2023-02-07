# frozen_string_literal: true

require "rails_helper"

describe Api::V1::RestaurantsController do
  describe "#create" do
    subject(:create) { post :create, params: params }
    let(:params) { { name: 'Restaurant 1', address: 'Address of Restaurant 1', description: 'Description of Restaurant 1' } }

    context "with valid user params" do
      it "creates a valid restaurant" do
        create

        expect(response).to have_http_status(201)
        expect(JSON.parse(response.body)["name"]).to eq('Restaurant 1')
      end
    end
  end

  describe '#index' do
    subject(:index) { get :index }
    let!(:restaurant) { create(:restaurant) }

    it 'returns all restaurant' do
      index
      
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)).not_to be_nil
    end
  end
end
