ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  if html_tag =~ /<label/
    html_tag.html_safe
  else
    object = instance_tag.object
    error_message = object.errors[instance_tag.method_name].to_sentence
    %{#{html_tag}<small class="error">#{error_message}</small>}.html_safe
  end
end
