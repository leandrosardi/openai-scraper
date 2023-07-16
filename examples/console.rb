require_relative '../lib/openai-scraper.rb'
require_relative '../config.rb'

l = BlackStack::LocalLogger.new('console.log')

l.log BlackStack::OpenAIScraper::NAME.green

l.logs "Initializing... "
BlackStack::OpenAIScraper.init
l.logf "done".green

# launch the console
l.log "Launching console:"
BlackStack::OpenAIScraper.console(l)

# finish
exit(0)

