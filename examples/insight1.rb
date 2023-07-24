# this example is about getting an insight about what a company is offering.

#require 'openai-scraper'
require_relative '../lib/openai-scraper'

=begin
## Insights to get from company websites
Reference: https://youtu.be/hxP88eQxLi4?t=621
- what is the main service offered by this company?
- what is the main product offered by this company?
- what are the features of the product?
- what is the vision of the company?
- what is the mission of the company?
- what are the processes of the company?
- what are the values of the company?
- what are can I improve to the product?

- last blog posts (title, description, author, date, link)
- last news (title, description, author, date, link)
- last events (title, description, author, date, link)
- last jobs (title, description, author, date, link) 

- build database of all articles written by the company members
=end

l = BlackStack::LocalLogger.new('insight1.log')

URLS = [
#    'schwartzbros.co.uk',
    'axinn.com',
    'melandrussin.com',
    'gitmeidlaw.com',
    'morganlewis.com',
    'willkie.com',
    'pacificalawgroup.com',
    'yettercoleman.com',
    'fujiwarasangyo.co.jp',
    'gunster.com',
    'mcgivneyandkluger.com',
    'murraylawpa.com',
    'wilmerhale.com',
    'smithlaw.com'
]

# setup the scraper
BlackStack::OpenAIScraper.set({
    :openai_apikey => '*****',
    :model => "gpt-3.5-turbo",
})

# initialize the scraper: OpenAI and Chrome browser are created.
l.logs 'initializing... '
BlackStack::OpenAIScraper.init
l.logf 'done'.green

=begin

# Example: sharing insights about an article with its author. 
# 

l.logs 'prompting... '
prompt = "Can you tell me the title, author and date of this article: \wt article: \\wt https://www.axinn.com/media-articles-277.html"
l.logf prompt.blue

# get the response
l.logs 'waiting for response... '
l.logf BlackStack::OpenAIScraper.response(prompt).green

l.logs 'prompting... '
prompt = "Get a 10-word insight about this article that completes this sentnce 'It is nice how the article explains...': \wt article: \\wt https://www.axinn.com/media-articles-277.html"
l.logf prompt.blue

# get the response
l.logs 'waiting for response... '
l.logf BlackStack::OpenAIScraper.response(prompt).green
=end


URLS.each do |url|
    begin
        l.logs "URL: #{url}... "
=begin
        # which one of these links is about the company mission
        l.logs 'prompting... '
#        prompt = "find the phone number of Joe Doe: \\wt http://#{url}"
        prompt = "find the main service offered by the company: \\wt http://#{url}"
        l.logf prompt.blue

        # get the response
        l.logs 'waiting for response... '
        response = BlackStack::OpenAIScraper.response(prompt)
        l.logf response.green
=end

# which one of these links is about the company mission
        l.logs 'prompting... '
        prompt = "choose and write the URL where I can find the list of offices of the company. It usually is the contact page: \\wl http://#{url}"
        l.logf prompt.blue

        # get the response
        l.logs 'waiting for response... '
        response = BlackStack::OpenAIScraper.response(prompt)
        l.logf response.green

        # extract an URL from the response
        l.logs 'extracting URL... '
        new_urls = URI.extract(response)
        new_url = new_urls.last 
        l.logf new_url.green

        l.logs 'prompting... '
        prompt = "get a list of locations of the company, and show address, postal code, email and phone number of each location in CSV format: \\wt #{new_url}"
        l.logf prompt.blue

        l.logs 'waiting for response... '
        l.logf BlackStack::OpenAIScraper.response(prompt).green
        l.done

=begin
        # get all links in the website, at a deep level of 3
        l.logs 'getting links... '
        links = BlackStack::OpenAIScraper.get_links("http://#{url}", 1, l)
        l.logf "done (#{links.size})".green

        # which one of these links is about the company mission
        l.logs 'prompting... '
        prompt = "choose and write the URL that is about the company mission: \\wl http://#{url}"
        l.logf prompt.blue

        # get the response
        l.logs 'waiting for response... '
        response = BlackStack::OpenAIScraper.response(prompt)
        l.logf response.green
=end

=begin
        # company mission
        l.logs 'prompting... '
        prompt = "write a 5-word sentence to describe the company mission and complete this sentence 'I respect your mission of': \\wt https://www.axinn.com/firm.html"
        l.logf prompt.blue
        
        # get the response
        l.logs 'waiting for response... '
        response = BlackStack::OpenAIScraper.response(prompt)
        l.logf response.green
=end

=begin
        # write a promopt
        l.logs 'prompting... '
        prompt = "Complete the sentence with no more than 5 words, describing a very unique service offered by this company 'I am looking for a company who offers...'. Here is the description text of the company: \\wt http://#{url}"
        l.logf prompt.blue

        # get the response
        l.logs 'waiting for response... '
        l.logf BlackStack::OpenAIScraper.response(prompt).green
=end
        l.done

    # rescue when the user press CTRL+C
    rescue Interrupt => e
        l.logf 'Process Interrumpted (e.g.: CTRL+C pressed). Exiting...'.red

        l.logs 'finalizing... '
        BlackStack::OpenAIScraper.finalize
        l.logf 'done'.green
        exit(0)

    rescue Exception => e
        l.logf e.message.red
        #l.logf e.backtrace    
    end # begin
end # URLS.each

l.logs 'finalizing... '
BlackStack::OpenAIScraper.finalize
l.logf 'done'.green
