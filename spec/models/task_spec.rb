require 'rails_helper'

RSpec.describe Task, type: :model do
  it "is valid with valid attributes" do
    expect(build(:task)).to be_valid
  end

  it "is invalid without title" do
    expect(build(:task, title: nil)).not_to be_valid
  end

  it "belongs to user" do
    should belong_to(:user)
  end
end
