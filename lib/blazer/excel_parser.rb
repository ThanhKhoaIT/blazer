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
          sheet.add_row row
        end
      end
    end

    def save_file!
      tmp_file = "tmp/#{filename}"
      excel.serialize(tmp_file)
      return tmp_file
    end

  end
end
