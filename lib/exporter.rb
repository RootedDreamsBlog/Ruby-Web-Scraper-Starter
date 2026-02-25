require "csv"
require "fileutils"

class Exporter
  def self.to_csv(data, filepath)
    return if data.empty?

    FileUtils.mkdir_p(File.dirname(filepath))

    CSV.open(filepath, "w", write_headers: true, headers: data.first.keys) do |csv|
      data.each { |row| csv << row.values }
    end

    puts "Exported #{data.size} rows to #{filepath}"
  rescue => e
    puts "Export failed: #{e.message}"
  end
end