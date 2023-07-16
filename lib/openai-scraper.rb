require 'nokogiri'
require 'mechanize'
require 'simple_cloud_logging'
require "openai"
require 'colorize'
require "io/console"

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
        @@openai_apikey = nil
        @@client = nil
        @@browser = nil
        @@history = []

        # hints to show in the terminal
        HINT1 = "HINT: The text below is a macr-generated prompt.".yellow

        # name of the module
        NAME = 'OpenAI Scraper'

        # pronto shown in the console
        PROMPT = 'openai-scraper'

        def self.set(h)
            @@openai_apikey = h[:openai_apikey] if h[:openai_apikey]
        end

        def self.init
            @@client = OpenAI::Client.new(access_token: @@openai_apikey)
            @@browser = Selenium::WebDriver.for :chrome
            # load history array from the file ./history.json, only if the file exists
            @@history = JSON.parse(File.read('./history.json')) if File.exist?('./history.json')
        end

        def self.finalize
            @@browser.quit
            # overrite the file ./history.json with the current history array
            File.write('./history.json', @@history.to_json)
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
            prompt = s
            # \wl <url>: download the web-page and pass the list of links to the model for further reference.\n
            # find the url after the `\wl`, when \wl may be at any position into the string
            i = 0
            s.split(' ').each { |x|
                if x == '\wl'
                    url = s.split(' ')[i+1]
                    prompt.gsub!(/\\wl #{url}/, BlackStack::OpenAIScraper.wl(url).to_s)
                end
                i += 1
            }
            #puts BlackStack::OpenAIScraper::HINT1
            #puts prompt.blue
                
            # \wt <url>: download the web-page and pass the text content to the model for further reference.\n 
            # find the url after the `\wl`, when \wl may be at any position into the string
            i = 0
            s.split(' ').each { |x|
                if x == '\wt'
                    url = s.split(' ')[i+1]
                    prompt.gsub!(/\\wt #{url}/, BlackStack::OpenAIScraper.wt(url).to_s)
                end
                i += 1
            }
            #puts BlackStack::OpenAIScraper::HINT1
            #puts prompt.blue

            response = @@client.chat(
                parameters: {
                    model: "gpt-3.5-turbo", # Required.
                    #max_tokens: 6000,
                    temperature: 0.5,
                    messages: [
                        { role: "user", content: prompt},
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

        # download the web page, and extract all links.
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

        # download the web page, and extract the text.
        #
        def self.wt(url)
            # visit the url
            @@browser.navigate.to url
            
            # wait up to 30 seconds for the page to load
            #wait = Selenium::WebDriver::Wait.new(:timeout => 30)
            #wait.until { @@browser.execute_script("return document.readyState") == "complete" }

            # wait up to 30 seconds for all ajax calls have been executed
            #wait = Selenium::WebDriver::Wait.new(:timeout => 30)
            #wait.until { @@browser.execute_script("return jQuery.active") == 0 }

            # return the text of the webpage
            @@browser.find_element(:tag_name, 'body').text
        end # def wt

        # show the promt and wait for the user input
        def self.console(l)
            l = BlackStack::DummyLogger.new(nil) if l.nil?
            begin
                while true
                    prompt = nil
                    print "#{BlackStack::OpenAIScraper::PROMPT}> ".blue
                    
                    # get the user input, char by char
                    s = ''
                    i = 0 
                    while true
                        c = $stdin.getch
                        # if the user press enter, then break the loop
                        if c == "\n" || c == "\r"
                            puts
                            @@history << s
                            i = 0
                            break
                        # if the user press backspace, then remove the last char from the string
                        elsif c == "\u007F"
                            if i >= 1
                                i -= 1
                                s = s[0..-2]
                                print "\b \b"
                            end
                        # if the user press ctrl+c, then reset the prompt
                        elsif c == "\u0003"
                            puts
                            break
                        # if the user press arrow-up
                        elsif c == "\e"
                            d = [$stdin.getch, $stdin.getch].join
                            if d == "[A" && @@history.size > 0
                                # remove the current prompt
                                print "\b \b" * s.size
                                # take the last prompt from the history
                                s = @@history[-1]
                                # remove the last promt from the history
                                @@history = @@history[0..-2]
                                # insert the prompt as the first in the history
                                @@history.insert(0, s)
                                # print the prompt
                                i = s.size
                                print s.strip
                            elsif d == "[B" && @@history.size > 0
                                # remove the current prompt
                                print "\b \b" * s.size
                                # take the first prompt from the history
                                s = @@history[0]
                                # remove the first promt from the history
                                @@history = @@history[1..-1]
                                # insert the prompt as the last in the history
                                @@history.insert(-1, s)
                                # print the prompt
                                i = s.size
                                print s.strip
                            end
                        else
                            s += c
                            i += 1
                            print c
                        end                        
                    end # while true
                
                    # `\q` to quit
                    if s == '\q'
                        exit(0)
                    # `\h` for help
                    elsif s == '\h'
                        puts BlackStack::OpenAIScraper.help 
                        next
                    else 
                        prompt = s
                    end
                    # standard openai prompt
                    puts BlackStack::OpenAIScraper.response(prompt).to_s.green
                end # while true
            
            rescue SignalException, SystemExit, Interrupt => e
                l.logs "Finalizing... "
                BlackStack::OpenAIScraper.finalize
                l.logf "done".green
            
                l.log 'Bye!'
                exit(0)
            rescue => e
                puts "Error: #{e.to_console.red}".red
            end # begin
        end # def console            

    end # module OpenAIScraper
end # module BlackStack