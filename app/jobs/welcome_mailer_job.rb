class WelcomeMailerJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 5

  def perform(*args)
    # Do something later
    user = User.find_by(id: user_id)

    if user
      user.send_welcome_email!
    else
      # handle a deleted user record
    end
  end
end
