# this example is about getting an insight about what a company is offering.

require 'openai-scraper'

# setup the scraper
BlackStack::OpenAIScraper.set({
    :openai_apikey => '*****',
    :model => "gpt-3.5-turbo",
})

# initialize the scraper: OpenAI and Chrome browser are created.
BlackStack::OpenAIScraper.init

# write a promopt
prompt = "can you nail what the CEO of this company is in need: \\wt https://www.rebeldesignbuild.com/"
prompt = "can you get the name of the team members of the company: \\wt https://www.rebeldesignbuild.com/about"

# get the response
puts BlackStack::OpenAIScraper.response(prompt).green
# => Leads Generation Service
