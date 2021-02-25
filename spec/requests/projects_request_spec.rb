require 'rails_helper'

RSpec.describe "Projects", type: :request do
  describe "#index" do
    #認証済みのユーザーとして
    context "as a authenticated user" do
      before do
        @user = FactoryBot.create(:user)
      end
      #正常にレスポンスを返すこと
      it "responds successfully returns a 200 response" do
        sign_in @user
        get projects_url
        expect(response).to be_successful
        expect(response).to have_http_status "200"
      end
    end
  end

  #ゲストとして
  context "as a guest" do
    it "returns a 302 response" do
      get projects_url
      expect(response).to have_http_status "302"
    end

    #サインイン画面にリダイレクトすること
    it "redirects to the sign-in page" do
      get projects_url
      expect(response).to redirect_to "/users/sign_in"
    end
  end
end
