module ApplicationHelper

  def present(object, klass= nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  def foundation_class_for flash_type
    { success: "success", error: "alert", alert: "warning", notice: "info" }[flash_type.to_sym] || flash_type.to_s
  end

  def admins_only(&block)
    block.call if current_user.try(:admin?)
  end

  def show_errors(object, field_name)
    if object.errors.any?
      if !object.errors.messages[field_name].blank?
        object.errors.messages[field_name].join(", ")
      end
    end
  end
end
