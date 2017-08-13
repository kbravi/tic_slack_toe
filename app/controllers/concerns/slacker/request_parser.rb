module Slacker
  module RequestParser

    # Extracts user's slack identifier from formatted slack message
    # E.g. <@U123455>, <@U123456|bob>
    # If the text isn't in the above format, just return the text as is.
    def extract_slack_user_identifier_from_text(text)
      if text.to_s.include? '|' and text.to_s.include? '<@' and text.to_s.include? '>'
        return text.to_s.split('|').first.to_s.split('<@').last
      elsif text.to_s.include? '<@' and text.to_s.include? '>'
        return text.to_s.split('>').first.to_s.split('<@').last
      else
        return text.to_s
      end
    end

    # Convert Json String to Hash
    def parse_json_string_to_hash(json_string)
      if json_string.present? and json_string.is_a? String
        return JSON.parse(json_string, :symbolize_names => true)
      else
        return json_string
      end
    end

  end
end
