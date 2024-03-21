FactoryBot.define do
  factory :review do
    content { "MyText" }
    rating { 1 }
    homeowner { nil }
    contractor { nil }
  end
end
