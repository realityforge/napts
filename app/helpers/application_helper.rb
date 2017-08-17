module ApplicationHelper
  def link_to_button(name, options = {}, html_options = nil, *parameters_for_method_reference)
    location = url_for(options, *parameters_for_method_reference)
    html_options = (html_options || {}).stringify_keys
    html_options['onclick'] = "location.href='#{location}';"
    html_options['type'] = 'button'
    content_tag('button', name, html_options)
  end

  def format_content(format,content,resource_base = {})
    output = TextFormatter.format_content(format,content)
    post_process(resource_base, output)
  end

  private

  def post_process(resource_base, output)
    while output =~ /\$\$resource\:(.*)\$\$/
      resource_base[:name] = $1
      output = "#{$`}#{url_for(resource_base)}#{$'}"
    end
    output
  end
end
