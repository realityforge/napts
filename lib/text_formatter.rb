class TextFormatter

  RedClothFormat = 1
  BlueClothFormat = 2
  RubyPantsFormat = 3
  PlainFormat = 4
  
  TEXT_FORMAT = {
    "RedCloth" => RedClothFormat,
    "BlueCloth" => BlueClothFormat,
    "RubyPants" => RubyPantsFormat,
    "Plain" => PlainFormat
  }.freeze

  def self.formatted_content(format,content)
    if format == RedClothFormat
      RedCloth.new( content ).to_html
    elsif format == BlueClothFormat
      BlueCloth::new( content ).to_html
    elsif format == RubyPantsFormat
      RubyPants.new( content ).to_html
    elsif format == PlainFormat
      content
    else
      raise 'Unknown format'
    end
  end

end
