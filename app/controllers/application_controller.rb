class ApplicationController < ActionController::Base

  protected

  def full_messages messages
    messages.join("\n")
  end
end
