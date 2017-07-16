class HeartsNotificationEmail
  def initialize(user)
    @user = user
  end

  def send
    return unless likes_email_allowed? && user_not_online
    HeartsMailer.new_hearts_notification(user).deliver_later
  end

  private

  attr_reader :user

  def likes_email_allowed?
    if user.email_preference.present?
      user.email_preference.likes
    else
      true
    end
  end

  def user_not_online
    user.is_signed_in ? false : true
  end
end
