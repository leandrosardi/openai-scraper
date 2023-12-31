![Gem version](https://img.shields.io/gem/v/openai-scraper) ![Gem downloads](https://img.shields.io/gem/dt/openai-scraper)

**This project is just starting... Follow me to keep updated!**

# OpenAI Scraper

OpenAI Chatbot, With the Ability to Take Information from the Web.

## Installation

```bash
gem install openai-scraper
```

## Usage

```ruby
# this example is about getting an insight about what a company is offering.

require 'openai-scraper'

# setup the scraper
BlackStack::OpenAIScraper.set({
    :openai_apikey => '<your openai api key here>',
})

# initialize the scraper: OpenAI and Chrome browser are created.
BlackStack::OpenAIScraper.init

# write a promopt
prompt = "can you craft a no more than 5-word description of what 
is the main service offered by this company, in order to complete 
this sentence \"I noticed that your company\". Please don't incude 
that sentence in your answer, and please don't add any final-dot 
at the end of your answer: \\wt https://connectionsphere.com/"

# get the response
puts BlackStack::OpenAIScraper.response(prompt).green
# => Leads Generation Service
```

## Further Work

- Implement [function calling](https://openai.com/blog/function-calling-and-other-api-updates) in replacement of current commands `\wl` and `\wt`

- Develop RPA features, using NPL (Natural Lenguage Processing) and CV (Computer Vision) for performing complex RPA (Robotic Process Automation) or Scraping tasks.