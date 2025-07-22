module ApplicationHelper
  def is_active_controller(controller_name)
    params[:controller] == controller_name ? 'active' : nil
  end

  def is_active_action(action_name)
    params[:action] == action_name ? 'active' : nil
  end

  def is_active_action?(action_name)
    params[:action] == action_name
  end

  def faty_list(elements)
    elements.map { |e| "<span class='label'>#{e}</span>" }.join(' ').html_safe
  end

  def state_yes_no(e)
    (e ? "<span class='label label-primary'>Oui</span>" : "<span class='label label-warning'>Non</span>").html_safe
  end

  def is_required_field?(model, field_name)
    result = false
    if model.respond_to?(:is_required_field?)
      result = model.is_required_field?(field_name)
    end

    result
  end

  def time_ago_in_words_custom(date_time)
    "#{time_ago_in_words(date_time)}"
  end
end
