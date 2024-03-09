class ConversationPolicy < ApplicationPolicy
  attr_reader :user, :conversation

  def initialize(user, conversation)
    @user = user
    @conversation = conversation
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
    user.present? && user == conversation.user # Only the sender of the message can update it
  end

  def reply?
    user.present? && (user.property_owner? || user.service_provider?) # Only homeowners and contractors can create messages
  end

  def destroy?
    user.present? && user == conversation.user # Only the sender of the message can delete it
  end
end