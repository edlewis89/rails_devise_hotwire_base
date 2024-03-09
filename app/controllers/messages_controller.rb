class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user, except: %i[index show]

  before_action do
    @conversation = Conversation.find(params[:conversation_id])
  end
  def index
    @messages = @conversation.messages
    if @messages.length > 10
      @over_ten = true
      @messages = @messages[-10..-1]
    end
    if params[:m]
      @over_ten = false
      @messages = @conversation.messages
    end
    if @messages.last
      if @messages.last.user_id != current_user.id
        @messages.last.update(read: true)
      end
    end
    @message = @conversation.messages.new
  end
  def new
    @message = @conversation.messages.new
  end
  def create
    @message = @conversation.messages.new(message_params)
    if @message.save
      redirect_to conversation_messages_path(@conversation)
    end
  end

  private

  def authorize_user
    message = @message || Message
    authorize message
  end

  def message_params
    params.require(:message).permit(:body, :user_id)
  end


  # def new
  #   #@message = Message.new
  #   @message = current_user.sent_messages.build
  #   @recipient_type = current_user.property_owner? ? "contractor" : "homeowner"
  #   @recipient_options = User.by_type(@recipient_type.capitalize)
  # end
  #
  # def create
  #   @message = Message.new(message_params)
  #   if @message.save
  #     # Handle successful message creation
  #   else
  #     # Handle failed message creation
  #   end
  # end
  #
  # def reply
  #   # Logic for replying to a message
  # end
  #
  # private
  #
  # def authorize_user
  #   message = @message || Message
  #   authorize message
  # end
  #
  # def message_params
  #   params.require(:message).permit(:sender_id, :recipient_id, :subject, :body)
  # end


  # def index
  #   @messages = current_user.received_messages.order(created_at: :desc)
  # end
  #
  # def show
  #   # Implement the logic to display a specific message
  # end
  #
  # def new
  #   @message = current_user.sent_messages.build
  #   @recipient_type = current_user.property_owner? ? "contractor" : "homeowner"
  #   @recipient_options = User.by_type(@recipient_type.capitalize)
  #   #@recipient_options = recipients.map { |user| [user.email, user.id] }
  #   set_recipient_info
  # end
  #
  # def reply
  #   @original_message = Message.find(params[:id])
  #   @reply_message = current_user.sent_messages.build(recipient_id: @original_message.sender_id)
  #   @recipient_options = [[@original_message.sender.email, @original_message.sender.id]]
  #
  #   #
  #   # @message = Message.find(params[:id])
  #   # @recipient_options = [[@message.sender.email, @message.sender.id]]
  #   # @reply_message = current_user.sent_messages.build
  #
  #   respond_to do |format|
  #     format.html # Render the HTML template for the reply form
  #     format.json { render json: { success: true } } # Respond with JSON if needed
  #   end
  # end
  #
  # def create_message
  #   @recipient = if params[:contractor_id]
  #                  Contractor.find(params[:contractor_id])
  #                elsif params[:homeowner_id]
  #                  Homeowner.find(params[:homeowner_id])
  #                end
  #
  #   @message = current_user.sent_messages.build(message_params)
  #   if @message.save
  #     # Broadcast the new message using Turbo Streams
  #     broadcast_new_message(@message)
  #     redirect_to show_message_url(@recipient), notice: "Message sent successfully."
  #   else
  #     render :new
  #   end
  # end
  #
  #
  # private
  #
  # def new_message_url(recipient)
  #   if recipient.is_a?(Contractor)
  #     new_contractor_message_path(recipient)
  #   elsif recipient.is_a?(Homeowner)
  #     new_homeowner_message_path(recipient)
  #   else
  #     raise ArgumentError, "Invalid recipient type"
  #   end
  # end
  #
  # def show_message_url(recipient)
  #   if recipient.is_a?(Contractor)
  #     contractor_messages_path(recipient)
  #   elsif recipient.is_a?(Homeowner)
  #     homeowner_messages_path(recipient)
  #   else
  #     raise ArgumentError, "Invalid recipient type"
  #   end
  # end
  #
  # def set_recipient_info
  #   if current_user.is_a?(Homeowner)
  #     @recipient_type = "Contractor"
  #     @recipient_options = Contractor.all.pluck(:email, :id)
  #   elsif current_user.is_a?(Contractor)
  #     @recipient_type = "Homeowner"
  #     @recipient_options = Homeowner.all.pluck(:email, :id)
  #   end
  # end
  #
  #
  # def broadcast_new_message(message)
  #   # Broadcast the new message to the conversation channel
  #   sender_conversation_channel = "user_#{message.sender_id}_conversation"
  #   recipient_conversation_channel = "user_#{message.recipient_id}_conversation"
  #
  #   ActionCable.server.broadcast(recipient_conversation_channel, turbo_stream.append("messages", message))
  #   ActionCable.server.broadcast(sender_conversation_channel, turbo_stream.append("messages", message))
  # end
  #
  # def authorize_user
  #   message = @message || Message
  #   authorize message
  # end
  #
  # def message_params
  #   params.require(:message).permit(:sender_id, :recipient_id, :subject, :body, :homeowner_id)
  # end
end
