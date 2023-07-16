require 'nokogiri'
require 'simple_cloud_logging'
require "openai"
require 'colorize'

module BlackStack
    module OpenAIScraper
        @@client = nil

        # hints to show in the terminal
        HINT1 = "HINT: The text below is a macr-generated prompt.".yellow

        # name of the module
        NAME = 'OpenAI Scraper'

        # pronto shown in the console
        PROMPT = 'openai-scraper'

        def self.init
            openai_apikey = OPENAI_APIKEY
            @@client = OpenAI::Client.new(access_token: openai_apikey)
        end            

        # help shown in the console
        def self.help
            "OpenAI Chatbot, With the Ability to Take Information from the Web.\n
List of Commands:\n
- \\q: quit\n
- \\wt <url>: download the web-page and pass the text content to the model for further reference.\n 
- \\wl <url>: download the web-page and pass the list of links to the model for further reference.\n
            "
        end

        def self.response(s)
            response = @@client.chat(
                parameters: {
                    model: "gpt-3.5-turbo", # Required.
                    messages: [{ role: "user", content: s}], # Required.
                    temperature: 0.7,
                })
            raise response.dig("error", "message") if response.dig("error", "message")
            return response.dig("choices", 0, "message", "content")         
        end

        # doanload the web page, and extract all links.
        # reutrn an openai prompt sharing all links in a json structure for further reference.
        def self.wl(url)
            # build the filename for the webpage
            filename = "/tmp/openai-scraper-#{Time.now.to_i}.html"

            # doanload the web page using Ruby libraries instead of call to bash commands
            # `wget -O #{filename} #{url}`
            uri = URI.parse(url)
            Net::HTTP.start(uri.host, uri.port) do |http|
                resp = http.get(uri.path)
                open(filename, "wb") do |file|
                    file.write(resp.body)
                end
            end
            
            # parse the html file
            doc = Nokogiri::HTML(open(filename))

            # extract all the links
            h = []
            doc.css('a').each do |link|
                txt = link.content.to_s.strip
                h << { 'href' => link['href'], 'text' => txt }
            end
binding.pry
            # return the prompt
            "I will share a json structure with with links. Please remember them for further reference:\n#{h.to_json}"
        end # def wl

    end # module OpenAIScraper
end # module BlackStack