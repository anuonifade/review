FactoryBot.define do
  factory :review do
    user
    restaurant
    description {"This is a sample review discription"}
    rating {rand(1..5)}
  end
end
