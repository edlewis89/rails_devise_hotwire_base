class MessagePolicy < ApplicationPolicy
  attr_reader :user, :message

  def initialize(user, message)
    @user = user
    @message = message
  end

  def index?
    user.present? # Any authenticated user can view messages
  end

  def show?
    user.present? && (user.property_owner? || user.service_provider?) # Only homeowners and contractors can view individual messages
  end

  def create_message?
    user.present? && (user.property_owner? || user.service_provider?) # Only homeowners and contractors can create messages
  end


  def create?
    user.present? && (user.property_owner? || user.service_provider?) # Only homeowners and contractors can create messages
  end

  def update?
    user.present? && user == message.sender # Only the sender of the message can update it
  end

  def reply?
    user.present? && (user.property_owner? || user.service_provider?) # Only homeowners and contractors can create messages
  end

  def destroy?
    user.present? && user == message.sender # Only the sender of the message can delete it
  end
end