ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "gmail.com",
  :user_name            => "jmharris9",
  :password             => "Polar99bear",
  :authentication       => "plain",
  :enable_starttls_auto => true
}