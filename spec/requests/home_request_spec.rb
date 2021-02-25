require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "#index" do
    #正常にレスポンスを返すこと
    it "responds successfully" do
      get root_path
      expect(response).to be_successful
    end
  end
end
