FactoryBot.define do
    factory :task do
      title { "Test Task" }
      description { "Task description" }
      status { "pending" }
      priority { 1 }
      due_date { Date.today + 1.day }
      association :user
  
      trait :completed do
        status { "completed" }
      end
    end
  end
  