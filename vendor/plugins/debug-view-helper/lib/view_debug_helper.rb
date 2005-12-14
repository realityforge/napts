# Derived from http://www.bigbold.com/snippets/posts/show/697
# Add something like the following to get debug output in separate popup
#  <botton onclick="show_debug_popup(); return false;">Show debug popup</button>
#  <%= debug_popup %>
module ViewDebugHelper
  
  def self.append_features(controller) #:nodoc:
    controller.ancestors.include?(ActionController::Base) ? controller.add_template_helper(self) : super
  end
    
  IGNORE = ["template_root", "template_class", "response", "template", "session", "url", "params", "subcategories", "ignore_missing_templates", "cookies", "request", "logger", "flash", "headers" ]

  def debug_popup
    popup_create do |script| 
      script << add( "<HTML><HEAD><TITLE>Rails Debug Console_#{@controller.class.name}</TITLE></HEAD><BODY bgcolor=#ffffff>" )
      script << add( "<table border=0 width=100%>" )
      script << add( "<tr bgcolor=#cccccc><th colspan=2>Rails Debug Console</th></tr>" )

      script << add( "<tr bgcolor=#cccccc><td colspan=2><b>request parameters:</b></td></tr>" )
      @controller.params.each do |key, value|
        script << add("<tr bgcolor=#eeeeee><td valign=top><tt><font color=blue>#{h key}</font></tt></td><td><tt><font color=green>#{h(value.inspect).gsub(/,/, ',<br/>')}</font></tt></td></tr>")  unless IGNORE.include?(key)          
      end unless @controller.params.nil?

      script << add( "<tr bgcolor=#cccccc><td colspan=2><b>session variables:</b></td></tr>" )
      @controller.session.instance_variable_get("@data").each do |key, value|      
        script << add("<tr bgcolor=#eeeeee><td valign=top><tt><font color=blue>#{h key}</font></tt></td><td><tt><font color=green>#{dump_obj(value)}</font></tt></td></tr>") unless IGNORE.include?(key)          
      end unless @controller.session.instance_variable_get("@data").nil?
      
      script << add( "<tr bgcolor=#cccccc><td colspan=2><b>flash variables:</b></td></tr>" )
      @controller.instance_variable_get("@flash").each do |key, value|
        script << add("<tr bgcolor=#eeeeee><td valign=top><tt><font color=blue>#{h key}</font></tt></td><td><tt><font color=green>#{dump_obj(value)}</font></tt></td></tr>") unless IGNORE.include?(key)
      end unless @controller.instance_variable_get("@flash").nil?

      script << add( "<tr bgcolor=#cccccc><td colspan=2><b>assigned template variables:</b></td></tr>" )      
      @controller.assigns.each do |key, value|
        script << add("<tr bgcolor=#eeeeee><td valign=top><tt><font color=blue>#{h key}</font></tt></td><td><tt><font color=green>#{dump_obj(value)}</font></tt></td></tr>") unless IGNORE.include?(key)
      end unless @controller.assigns.nil?
    end
  end

  private
  
  def popup_create
    script = "<script language='javascript'>\n<!--\n"
    script << "function show_debug_popup() {\n"
    script << "_rails_console = window.open(\"\",\"#{@controller.class.name}\",\"width=680,height=600,resizable,scrollbars=yes\");\n"
    yield script
    script << "_rails_console.document.close();\n"
    script << "}\n"
    script << "-->\n</script>"
  end
  
  def add(msg)
    "_rails_console.document.write(\"#{msg}\")\n"
  end  

  def dump_obj(object)
    begin
      Marshal::dump(object)
      "<pre>#{h(object.to_yaml).gsub("  ", "&nbsp; ").gsub("\n", "<br/>\"+\n\"" )}</pre>"
    rescue Object => e
      # Object couldn't be dumped, perhaps because of singleton methods -- this is the fallback
      "<pre>#{h(object.inspect)}</pre>"
    end
  end
end
