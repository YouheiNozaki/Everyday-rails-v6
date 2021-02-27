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
        get projects_path
        expect(response).to be_successful
        expect(response).to have_http_status "200"
      end
    end
    #ゲストとして
    context "as a guest" do
      it "returns a 302 response" do
        get projects_path
        expect(response).to have_http_status "302"
      end

      #サインイン画面にリダイレクトすること
      it "redirects to the sign-in page" do
        get projects_path
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
        get projects_path, params: { id: @project.id }
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
        # このパス指定のやり方がわからない
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

      #有効な属性値の場合
      context "with valid attributes" do
        #プロジェクトを追加できること
        it "adds a project" do
          project_params = FactoryBot.attributes_for(:project)
          sign_in @user
          expect {
            post projects_path, params: { project: project_params }
          }.to change(@user.projects, :count).by(1)
        end
      end

      #無効な属性値の場合
      context "with invalid attributes" do
        #プロジェクトを追加できないこと
        it "does not add a project" do
          project_params = FactoryBot.attributes_for(:project, :invalid)
          sign_in @user
          expect {
            post projects_path, params: { project: project_params }
          }.to_not change(@user.projects, :count)
        end
      end
    end

    #ゲストとして
    context "as a guest" do
      #302レスポンスを返すこと
      it "returns a 302 response" do
        project_params = FactoryBot.attributes_for(:project)
        post projects_path, params: { project: project_params }
        expect(response).to have_http_status "302"
      end

      #サインイン画面にリダイレクトすること
      it "redirects to the sign-in page" do
        project_params = FactoryBot.attributes_for(:project)
        post projects_path, params: { project: project_params }
        expect(response).to redirect_to "/users/sign_in"
      end
    end
  end
  describe "#update" do
    context "as an authorized user" do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: @user)
      end

      #プロジェクトを更新できること
      it "updates a project" do
        project_params = FactoryBot.attributes_for(:project, name: "New Project Name")
        sign_in @user
        patch project_url @project, params: { project: project_params }
        expect(@project.reload.name).to eq "New Project Name"
      end
    end
    #認可されていないユーザーとして
    context "as an unauthorized user" do
      before do
        @user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        @project = FactoryBot.create(
          :project,
          owner: other_user,
          name: "Same Old Name"
        )
      end

      #プロジェクトを更新できないこと
      it "does not update the project" do
        project_params = FactoryBot.attributes_for(:project, name: "New Name")
        sign_in @user
        patch project_url @project, params: { project: project_params }
        expect(@project.reload.name).to eq "Same Old Name"
      end
      #ダッシュボードヘリダイレクトすること
      it "redirect to the dashboard" do
        project_params = FactoryBot.attributes_for(:project)
        sign_in @user
        patch project_url @project, params: { project: project_params }
        expect(response).to redirect_to root_path
      end
    end
    #ゲストとして
    context "as a guest" do
      before do
        @project = FactoryBot.create(:project)
      end
      #302レスポンスを返す
      it "returns a 302 response" do
        project_params = FactoryBot.attributes_for(:project)
        patch project_url @project, params: { project: project_params }
        expect(response).to have_http_status "302"
      end
      #サインイン画面にリダイレクトすること
      it "redirects to the sign-in page" do
        project_params = FactoryBot.attributes_for(:project)
        patch project_url @project, params: { project: project_params }
        expect(response).to redirect_to "/users/sign_in"
      end
    end
  end
  describe "#destroy" do
    #認可されたユーザーとして
    context "as an authorized user" do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: @user)
      end
      #プロジェクトを削除できること
      it "deletes a project" do
        project_params = FactoryBot.attributes_for(:project)
        sign_in @user
        expect {
          delete project_url @project, params: { project: project_params }
        }.to change(@user.projects, :count).by(-1)
      end
    end
    #認可されていないユーザーとして
    context "as an unauthorized user" do
      before do
        @user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: other_user)
      end
      #プロジェクトを削除できないこと
      it "does not delete the project" do
        project_params = FactoryBot.attributes_for(:project)
        sign_in @user
        expect {
          delete project_url @project, params: { project: project_params }
        }.to_not change(Project, :count)
      end
      #ダッシュボードにリダイレクトすること
      it "redirects to the dashboard" do
        project_params = FactoryBot.attributes_for(:project)
        sign_in @user
        delete project_url @project, params: { project: project_params }
        expect(response).to redirect_to root_path
      end
    end
    #ゲストとして
    context "as a guest" do
      before do
        @project = FactoryBot.create(:project)
      end
      #302レスポンスを返すこと
      it "returns a 302 response" do
        project_params = FactoryBot.attributes_for(:project)
        delete project_url @project, params: { project: project_params }
        expect(response).to have_http_status "302"
      end
      #サインイン画面にリダイレクトすること
      it "redirects to the sign-in page" do
        project_params = FactoryBot.attributes_for(:project)
        delete project_url @project, params: { project: project_params }
        expect(response).to redirect_to "/users/sign_in"
      end
      #プロジェクトを削除できないこと
      it "does not delete the project" do
        project_params = FactoryBot.attributes_for(:project)
        expect {
          delete project_url @project, params: { project: project_params }
        }.to_not change(Project, :count)
      end
    end
  end
end
