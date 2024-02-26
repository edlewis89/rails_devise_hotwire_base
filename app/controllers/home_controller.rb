class HomeController < ApplicationController
  def index
    # Check if the user is not signed in
    unless user_signed_in?
      # Render the sign-in form
      redirect_to new_user_session_path
    end
  end

  def send_data
    Turbo::StreamsChannel.broadcast_replace_to(
      "hello_stream",
      target: "hello_frame",
      partial: "home/hello"
    )
    head :ok
  end
end
