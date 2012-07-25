module ApplicationHelper
  def render_flash(flash)
    # Maps each flash message type to the corresponding foundation alert
    # CSS classes
    flash_types = {
      :alert  => 'alert-box alert',
      :notice => 'alert-box success'
    }

    output = ''.html_safe

    flash_types.each do |type, classes|
      if flash[type]
        output.concat(content_tag(:div, flash[type], :class => classes))
      end
    end

    return output
  end
end
