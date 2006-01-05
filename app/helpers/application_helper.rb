module ApplicationHelper
  def link_to_button(name, options = {}, html_options = nil, *parameters_for_method_reference)
    location = url_for(options, *parameters_for_method_reference)
    html_options = (html_options || {}).stringify_keys
    html_options['onclick'] = "location.href='#{location}';"
    html_options['type'] = 'button'
    content_tag('button', name, html_options)
  end
end
