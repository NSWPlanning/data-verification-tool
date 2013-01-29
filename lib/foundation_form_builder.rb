class FoundationFormBuilder < ActionView::Helpers::FormBuilder

  include ActionView::Helpers::TagHelper

  field_helpers.each do |helper|
    define_method helper do |field, options = {}|
      if @object.errors.include? field
        options[:class] = [options[:class], 'error'].compact.join(' ')
      end
      super(field, options)
    end
  end

  def submit(value = 'Save Changes', options = {})
    options[:class] = 'button radius'
    super(value, options)
  end

  def error_messages(options = {})
    if @object.errors.any?
      list_items = @object.errors.full_messages.inject(''.html_safe) do |memo, message|
        memo.concat(content_tag(:li, message))
      end
      ul = content_tag(:ul, list_items)
      content_tag(:div, ul, :class => 'alert-box alert')
    end
  end

end
