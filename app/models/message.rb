class Message < ApplicationRecord
  #belongs_to :sender, class_name: "User"
  #belongs_to :recipient, class_name: "User"

  belongs_to :conversation
  belongs_to :user
  validates_presence_of :body, :conversation_id, :user_id

  def message_time
    created_at.strftime("%m/%d/%y at %l:%M %p")
  end
end
