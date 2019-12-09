module Blazer
  class ExcelParser

    def initialize(query, columns, rows)
      @query = query
      @columns = columns
      @rows = rows
      @excel = ::Axlsx::Package.new
    end

    def export
      load_data!
      save_file!
    end

    def filename
      "#{query.name.to_s.parameterize}-#{Time.current.strftime('%y-%m-%d')}.xlsx"
    end

    private

    attr_reader :query, :excel

    def load_data!
      excel.workbook.add_worksheet(name: "ID #{query.id}") do |sheet|
        sheet.add_row @columns
        @rows.each do |row|
          sheet.add_row row.each_with_index.map { |v, i| v.is_a?(Time) ? blazer_time_value(@columns[i], v) : v }
        end
      end
    end

    def save_file!
      tmp_file = Tempfile.new(filename).path
      excel.serialize(tmp_file)
      return tmp_file
    end

    def blazer_time_value(key, value)
      value_with_time_zone = (value.in_time_zone(Blazer.time_zone) rescue value)
      if key.end_with?('_date')
        value_with_time_zone.strftime("%Y/%m/%d")
      elsif key.end_with?('_time')
        value_with_time_zone.strftime("%H:%M")
      elsif data_source.local_time_suffix.any? { |s| key.ends_with?(s) }
        value.to_s.sub(" UTC", "")
      else
        value_with_time_zone
      end
    rescue
      return value
    end

  end
end
