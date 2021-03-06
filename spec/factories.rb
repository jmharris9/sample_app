FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}  
    sequence(:user_name) { |n| "#{n}userguy"} 
    password "foobar"
    password_confirmation "foobar"
 	
 	  factory :admin do
      admin true
    end
  end

  factory :micropost do
    sequence(:content) { |n| "Lorem ipsum #{n}" }
    user
  end
  
  factory :message do
    sequence(:content) { |n| "d Lorem ipsum #{n}" }
    user
  end
end