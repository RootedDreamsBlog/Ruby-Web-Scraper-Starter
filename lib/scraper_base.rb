require "httparty"
require "nokogiri"
require "logger"
require "fileutils"

class ScraperBase
  attr_reader :logger

  def initialize
    FileUtils.mkdir_p("logs")
    @logger = Logger.new("logs/scraper.log")
    @logger.level = Logger::INFO
  end

  def fetch_page(url, headers = {})
    default_headers = {
      "User-Agent" => "Mozilla/5.0 (compatible; RubyScraper/1.0)"
    }
    response = HTTParty.get(url, headers: default_headers.merge(headers))
    raise "HTTP Error: #{response.code}" unless response.success?

    Nokogiri::HTML(response.body)
  rescue => e
    logger.error("Failed to fetch #{url}: #{e.message}")
    nil
  end

  def fetch_with_retry(url, max_retries: 3)
    attempts = 0
    begin
      attempts += 1
      fetch_page(url)
    rescue => e
      if attempts < max_retries
        wait = 2 ** attempts
        logger.warn("Retry #{attempts}/#{max_retries} for #{url} — waiting #{wait}s")
        sleep(wait)
        retry
      else
        logger.error("Giving up on #{url} after #{max_retries} attempts: #{e.message}")
        nil
      end
    end
  end
end