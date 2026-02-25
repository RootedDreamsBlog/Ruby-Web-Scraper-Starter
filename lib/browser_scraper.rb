require "ferrum"
require "nokogiri"
require_relative "scraper_base"

class BrowserScraper < ScraperBase
  def initialize
    super
    @browser = Ferrum::Browser.new(
      headless: true,
      timeout: 30,
      browser_options: { "no-sandbox": nil }
    )
  end

  def scrape(url:, selectors:, wait_for: nil)
    @browser.goto(url)

    # Optionally wait for a specific element to appear
    @browser.at_css(wait_for).wait if wait_for

    doc = Nokogiri::HTML(@browser.body)
    results = []

    doc.css(selectors[:item]).each do |node|
      results << {
        title: node.css(selectors[:title]).text.strip,
        link:  node.css(selectors[:link]).attr("href"),
        price: node.css(selectors[:price])&.text&.strip
      }
    end

    logger.info("Browser scraped #{results.size} items from #{url}")
    results
  rescue => e
    logger.error("Browser scraping failed: #{e.message}")
    []
  ensure
    @browser.quit
  end
end