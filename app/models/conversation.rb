class Conversation < ActiveRecord::Base
  belongs_to :sender, :foreign_key => :sender_id, class_name: 'User'
  belongs_to :recipient, :foreign_key => :recipient_id, class_name: 'User'
  has_many :messages, dependent: :destroy

  validates_uniqueness_of :sender_id, :scope => :recipient_id
  
  scope :between, -> (sender_id, recipient_id) do
    where("(conversations.sender_id = ? AND conversations.recipient_id =?) OR (conversations.sender_id = ? AND conversations.recipient_id =?)", sender_id,recipient_id, recipient_id, sender_id)
  end

  # Method to count unread messages in the conversation
  def unread_messages_count(user_id)
    messages.where(user_id: recipient_id, read: false).count if user_id == sender_id
    messages.where(user_id: sender_id, read: false).count if user_id == recipient_id
  end

  # Method to get received conversations for a user
  def self.received_conversations(user_id)
    where(recipient_id: user_id)
  end

  # Method to count unread messages in all received conversations for a user
  def self.unread_messages_count(user_id)
    received_conversations(user_id).sum { |conversation| conversation.unread_messages_count(user_id) }
  end

  private
end