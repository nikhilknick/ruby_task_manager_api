require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = build(:user)
    expect(user).to be_valid
  end
  it "is invalid without email" do
    user = build(:user, email: nil)
    expect(user).not_to be_valid
  end
  it "is invalid without password" do
    user = build(:user, password: nil)
    expect(user).not_to be_valid
  end
  it "has many tasks" do
    should have_many(:tasks).dependent(:destroy)
  end
end
