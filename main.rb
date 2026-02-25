require "yaml"
require_relative "lib/static_scraper"
require_relative "lib/browser_scraper"
require_relative "lib/exporter"

config   = YAML.load_file("config/scraper_config.yml")
settings = config["scraper"]
all_results = []

config["targets"].each do |target|
  puts "→ Scraping [#{target["type"]}]: #{target["name"]}"

  selectors = target["selectors"].transform_keys(&:to_sym)

  scraper = case target["type"]
            when "browser" then BrowserScraper.new
            else StaticScraper.new
            end

  results = scraper.scrape(url: target["url"], selectors: selectors)
  all_results.concat(results)

  sleep(settings["delay_between_requests"])
end

Exporter.to_csv(all_results, settings["output_file"])