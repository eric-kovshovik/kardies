class MessagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    @recipient ||= User.find_by(username: params[:message][:username])
    redirect_to users_path if @recipient == current_user
    send_message
  end

  private

  def send_message
    conversation = find_existing_conversation
    if conversation && !conversation_deleted?(conversation)
      current_user.reply_to_conversation(conversation, params[:message][:body])
    else
      conversation = current_user.send_message(
        @recipient,
        params[:message][:body],
        current_user.username
      ).conversation
      flash[:success] = t '.sent'
    end
    redirect_to conversation_path(conversation)
    add_conversation_notification
    conversation_notification_email
  end

  def add_conversation_notification
    ConversationNotification.create(user_id: @recipient.id,
                                    receiver_id: current_user.id,
                                    received: true)
  end

  def conversation_notification_email
    @conversation_notification_email ||=
      ConversationsNotificationEmail.new(@recipient).send_email
  end

  def find_existing_conversation
    Mailboxer::Conversation
      .between(current_user, @recipient)
      .find { |c| c.participants.count == 2 }
  end

  def conversation_deleted?(conversation)
    conversation.is_deleted?(current_user)
  end
end
