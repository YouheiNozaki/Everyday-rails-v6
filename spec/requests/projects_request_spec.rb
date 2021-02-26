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
  describe "#show" do
    #認可されたユーザーとして
    context "as an authorized user" do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: @user)
      end
      #正常にレスポンスを返すこと
      it "responds successfully returns a 200 response" do
        sign_in @user
        get project_url @project.id
        expect(response).to be_successful
      end
    end
    #認可されていないユーザーとして
    context "as an unauthorized user" do
      before do
        @user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: other_user)
      end
      #ダッシュボードにリダイレクトすること
      it "redirects to the dashboard" do
        sign_in @user
        get project_url @project.id
        expect(response).to redirect_to root_path
      end
    end
  end
  describe "#create" do
    #認証済みのユーザーとして
    context "as an authenticated user" do
      before do
        @user = FactoryBot.create(:user)
      end

      #プロジェクトを追加できること
      it "adds a project" do
        project_params = FactoryBot.attributes_for(:project)
        sign_in @user
        expect {
          post projects_url, params: { project: project_params }
        }.to change(@user.projects, :count).by(1)
      end
    end

    #ゲストとして
    context "as a guest" do
      #302レスポンスを返すこと
      it "returns a 302 response" do
        project_params = FactoryBot.attributes_for(:project)
        post projects_url, params: { project: project_params }
        expect(response).to have_http_status "302"
      end

      #サインイン画面にリダイレクトすること
      it "redirects to the sign-in page" do
        project_params = FactoryBot.attributes_for(:project)
        post projects_url, params: { project: project_params }
        expect(response).to redirect_to "/users/sign_in"
      end
    end
  end
end
