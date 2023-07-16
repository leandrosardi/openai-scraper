require 'nokogiri'
require 'mechanize'
require 'simple_cloud_logging'
require "openai"
require 'colorize'

# require selenium
require 'selenium-webdriver'

=begin
def get_current_weather(location:, unit: "fahrenheit")
    # use a weather api to fetch weather
    { "temperature": 22, "unit": "celsius", "description": "Sunny" }
end

def wl(url)
    BlackStack::OpenAIScraper.wl(url)
end
=end

module BlackStack
    module OpenAIScraper
        @@client = nil
        @@browser = nil

        # hints to show in the terminal
        HINT1 = "HINT: The text below is a macr-generated prompt.".yellow

        # name of the module
        NAME = 'OpenAI Scraper'

        # pronto shown in the console
        PROMPT = 'openai-scraper'

        def self.init
            @@client = OpenAI::Client.new(access_token: OPENAI_APIKEY)
            @@browser = Selenium::WebDriver.for :chrome
        end            

        def self.finalize
            @@browser.quit
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
                    messages: [
                        { role: "user", content: s},
                        #{ role: "assistant", content: nil, function_call: {name: "get_current_weather", arguments: { location: "Boston, MA"}}},
                        #{ role: "function", name: "get_current_weather", content: { temperature: "22", unit: "celsius", description: "Sunny"}},

                    ], # Required.
=begin
                    functions: [
                        {
                            name: "wl",
                            description: "Extract the links from a web page",
                            parameters: {
                                type: :object,
                                properties: {
                                    url: {
                                        type: "string",
                                        description: "The url of the web page"    
                                    },
                                },
                                required: ['url'],
                            },
                        },
                        {
                            name: "get_current_weather",
                            description: "Get the current weather in a given location",
                            parameters: {
                                type: :object,
                                properties: {
                                    location: {
                                        type: :string,
                                        description: "The city and state, e.g. San Francisco, CA",
                                    },
                                    unit: {
                                        type: "string",
                                        enum: %w[celsius fahrenheit],
                                    },
                                },
                                required: ["location"],
                            },
                        },
                    ],
=end
                })
            raise response.dig("error", "message") if response.dig("error", "message")
            return response.dig("choices", 0, "message", "content")         
        end

        # doanload the web page, and extract all links.
        # reutrn an openai prompt sharing all links in a json structure for further reference.
        #
        # example: \wl https://leadhype.com/
        # example: What is the contact page in this list of links \wl https://leadhype.com/
        # example: Give me all the links in this URL: https://leadhype.com/
        #
        def self.wl(url)
            # visit the url
            @@browser.navigate.to url
            
            # wait up to 30 seconds for the page to load
            #wait = Selenium::WebDriver::Wait.new(:timeout => 30)
            #wait.until { @@browser.execute_script("return document.readyState") == "complete" }

            # wait up to 30 seconds for all ajax calls have been executed
            #wait = Selenium::WebDriver::Wait.new(:timeout => 30)
            #wait.until { @@browser.execute_script("return jQuery.active") == 0 }

            # get all the links
            links = @@browser.find_elements(:tag_name, 'a')

            # add the links to a json structure
            h = []
            links.each do |link|
                txt = link.text.to_s.strip
                h << { 'href' => link['href'], 'text' => txt }
            end

            # return the prompt
            #"I will share a json structure with with links. Please remember them for further reference:\n#{h.join("\n").to_json}"
            #"I have the links in a webpage. Which one of these links is the link to the \"contact us\" page of the company? \n #{h.join("\n")}"
            h
        end # def wl

    end # module OpenAIScraper
end # module BlackStack