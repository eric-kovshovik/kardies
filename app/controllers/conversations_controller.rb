class ConversationsController < ApplicationController
  before_action :get_mailbox, :get_messages
  before_action :get_conversation, except: %i[index empty_trash]

  def index
    @conversations
    @conversations_trash = @mailbox.trash.page(params[:page]).per(10)
    delete_conversation_notifications
  end

  def show
    redirect_to conversations_path if @conversation.is_deleted?(current_user)
    @conversation.mark_as_read(current_user) if @conversation.is_unread?(current_user)
    @hashed_conversation = EncryptId.new(@conversation.id).encrypt
  end

  def reply
    current_user.reply_to_conversation(@conversation, params[:body])
    redirect_to conversation_path(@conversation)
  end

  def destroy
    @conversation.move_to_trash(current_user)
    flash[:success] = (t '.convo_trashed').to_s
    respond_to do |format|
      format.html { redirect_to conversations_path }
      format.json { head :ok }
    end
  end

  def restore
    @conversation.untrash(current_user)
    flash[:success] = (t '.convo_restored').to_s
    redirect_to conversations_path
  end

  def empty_trash
    @mailbox.trash.each do |conversation|
      conversation.receipts_for(current_user).mark_as_deleted
    end
    flash[:success] = (t '.trash_cleaned').to_s
    respond_to do |format|
      format.html { redirect_to conversations_path }
      format.json { head :ok }
    end
  end

  private

  def get_mailbox
    @mailbox ||= current_user.mailbox
  end

  def get_messages
    messages = @mailbox.inbox + @mailbox.sentbox
    @conversations = messages.flatten.uniq(&:id) # remove duplicate IDs
  end

  def get_conversation
    @conversation ||= @mailbox.conversations.find(params[:id])
  end

  def delete_conversation_notifications
    current_user.conversation_notifications.destroy_all
  end
end
