Gem::Specification.new do |s|
    s.name        = 'openai-scraper'
    s.version     = '1.3'
    s.date        = '2023-07-24'
    s.summary     = "Ruby library for automation operation on the GMass Deliverability Test and Spam Checker."
    s.description = "Find documentation here: https://github.com/leandrosardi/openai-scraper"
    s.authors     = ["Leandro Daniel Sardi"]
    s.email       = 'leandro@connectionsphere.com'
    s.files       = [
      'lib/openai-scraper.rb',
    ]
    s.homepage    = 'https://rubygems.org/gems/openai-scraper'
    s.license     = 'MIT'
    s.add_runtime_dependency 'nokogiri', '~> 1.13.10', '>= 1.13.10'
    s.add_runtime_dependency 'mechanize', '~> 2.8.5', '>= 2.8.5'
    s.add_runtime_dependency 'simple_cloud_logging', '~> 1.2.2', '>= 1.2.2'
    s.add_runtime_dependency 'colorize', '~> 0.8.1', '>= 0.8.1'
    #s.add_runtime_dependency 'selenium-webdriver', '~> 4.10.0', '>= 4.10.0'
    s.add_runtime_dependency 'ruby-openai', '~> 4.2.0', '>= 4.2.0'
    s.add_runtime_dependency 'io-console', '~> 0.5.11', '>= 0.5.11'
end