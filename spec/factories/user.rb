FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name { "Doe" }
    email {"johndoe@doe.com"}
    password {"abc123"}
  end
end
