require 'rails_helper'

RSpec.describe "Tasks API", type: :request do
  let(:user) { create(:user) }

  describe "GET /tasks" do
    before { create_list(:task, 3, user: user) }

    it "returns all tasks" do
      get "/tasks"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).length).to eq(3)
    end
  end

  describe "GET /tasks/:id" do
    it "returns a task" do
      task = create(:task, user: user)

      get "/tasks/#{task.id}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["id"]).to eq(task.id)
    end
  end

  describe "POST /tasks" do
    it "creates a task" do
        expect {
          post "/tasks", params: {
            task: {
              title: "New Task",
              status: "pending",
              user_id: user.id
            }
          }
        }.to change(Task, :count).by(1)
      
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)["title"]).to eq("New Task")
    end
  end

  describe "PUT /tasks/:id" do
    it "updates a task" do
      task = create(:task, user: user)

      put "/tasks/#{task.id}", params: { task: { title: "Updated Task" } }

      expect(response).to have_http_status(:ok)
      expect(task.reload.title).to eq("Updated Task")
    end
  end

  describe "DELETE /tasks/:id" do
    it "deletes a task" do
      task = create(:task, user: user)

      expect {
        delete "/tasks/#{task.id}"
      }.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
