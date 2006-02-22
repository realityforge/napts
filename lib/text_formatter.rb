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

  def self.format_content(format,content)
    case format
    when RedClothFormat  then RedCloth.new( content ).to_html
    when BlueClothFormat then BlueCloth::new( content ).to_html
    when RubyPantsFormat then RubyPants.new( content ).to_html
    when PlainFormat     then content
    else                      raise 'Unknown format'
    end
  end
end
