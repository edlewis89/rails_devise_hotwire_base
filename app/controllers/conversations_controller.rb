class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: %i[index show]

  def index
    if current_user.property_owner?
      @users = User.where(role: :service_provider)
    elsif current_user.service_provider?
      @users = User.where(role: :property_owner)
    else
      @users = User.none
    end
    @conversations = Conversation.all
  end
  def create
    binding.pry
    if Conversation.between(params[:sender_id],params[:recipient_id]).present?
      @conversation = Conversation.between(params[:sender_id], params[:recipient_id]).first
    else
      @conversation = Conversation.create!(conversation_params)
    end
    redirect_to conversation_messages_path(@conversation)
  end
  private

  def authorize_user
    conversation = @conversation || Conversation
    authorize conversation
  end

  def conversation_params
    params.require(:conversation).permit(:sender_id, :recipient_id)
  end
end