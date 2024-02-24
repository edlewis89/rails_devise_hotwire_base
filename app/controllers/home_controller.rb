class HomeController < ApplicationController
  def index
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
