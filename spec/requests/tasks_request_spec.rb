require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  let(:headers) do
    { 'Accept' => 'application/json' }
  end
  before do
    @user = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, owner: @user)
    @task = @project.tasks.create!(name: "Test task")
  end

  describe "#show" do
    #JSON形式でレスポンスを返すこと
    it "responds with JSON formatted output" do
      sign_in @user
      get projects_url, headers: headers, params: { project_id: @project.id, id: @task.id }
      expect(response.content_type).to eq "application/json"
    end
  end
  describe "#create" do
    #JSON形式でレスポンスを返すこと
    it "responds with JSON formatted output" do
      new_task = { name: "New test task" }
      sign_in @user
      post project_tasks_url(@project), headers: headers, params: { task: new_task }
      expect(response.content_type).to eq "application/json"
    end
  end
end
