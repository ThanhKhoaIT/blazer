module Blazer
  module BaseHelper
    def blazer_title(title = nil)
      if title
        content_for(:title) { title }
      else
        content_for?(:title) ? content_for(:title) : nil
      end
    end

    BLAZER_URL_REGEX = /\Ahttps?:\/\/[\S]+\z/
    BLAZER_IMAGE_EXT = %w[png jpg jpeg gif]

    def blazer_format_value(key, value)
      if value.is_a?(Numeric) && !key.to_s.end_with?("id") && !key.to_s.start_with?("id")
        number_with_delimiter(value, delimiter: ',', separator: '.')
      elsif value =~ BLAZER_URL_REGEX
        # see if image or link
        if Blazer.images && (key.include?("image") || BLAZER_IMAGE_EXT.include?(value.split(".").last.split("?").first.try(:downcase)))
          link_to value, target: "_blank" do
            image_tag value, referrerpolicy: "no-referrer"
          end
        else
          link_to value, value, target: "_blank"
        end
      elsif key.end_with?("_date")
        value.in_time_zone(Blazer.time_zone).strftime('%Y/%m/%d') rescue value
      elsif key.end_with?("_time")
        value.in_time_zone(Blazer.time_zone).strftime('%H:%M') rescue value
      else
        value
      end
    end

    def blazer_maps?
      Blazer.mapbox_access_token.present?
    end

    def blazer_js_var(name, value)
      "var #{name} = #{blazer_json_escape(value.to_json(root: false))};".html_safe
    end

    JSON_ESCAPE = { '&' => '\u0026', '>' => '\u003e', '<' => '\u003c', "\u2028" => '\u2028', "\u2029" => '\u2029' }
    JSON_ESCAPE_REGEXP = /[\u2028\u2029&><]/u

    # Prior to version 4.1 of rails double quotes were inadventently removed in json_escape.
    # This adds the correct json_escape functionality to rails versions < 4.1
    def blazer_json_escape(s)
      if Rails::VERSION::STRING < "4.1"
        result = s.to_s.gsub(JSON_ESCAPE_REGEXP, JSON_ESCAPE)
        s.html_safe? ? result.html_safe : result
      else
        json_escape(s)
      end
    end

    def blazer_series_name(k)
      k.nil? ? "null" : k.to_s
    end
  end
end
