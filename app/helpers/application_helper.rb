module ApplicationHelper
  def link_to_button(name, options = {}, html_options = nil, *parameters_for_method_reference)
    location = url_for(options, *parameters_for_method_reference)
    options = {"onclick" => "location.href='#{location}'; return false;"}.update(options.stringify_keys)
    content_tag("button", name, options)
  end
end
