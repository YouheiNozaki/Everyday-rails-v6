require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "#index" do
    #正常にレスポンスを返すこと
    it "responds successfully returns a 200 response" do
      get root_path
      expect(response).to be_successful
      expect(response).to have_http_status "200"
    end
  end
end
