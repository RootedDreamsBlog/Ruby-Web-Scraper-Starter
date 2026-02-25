require_relative "scraper_base"

class StaticScraper < ScraperBase
  def scrape(url:, selectors:)
    doc = fetch_page(url)
    return [] if doc.nil?

    results = []
    doc.css(selectors[:item]).each do |node|
      results << {
        title: node.css(selectors[:title]).text.strip,
        link:  node.css(selectors[:link]).attr("href")&.value,
        price: node.css(selectors[:price])&.text&.strip
      }
    end

    logger.info("Scraped #{results.size} items from #{url}")
    results
  end
end