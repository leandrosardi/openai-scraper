require_relative './lib/openai-scraper.rb'
require_relative './config.rb'

filename = './hgwarchitecture.html'
l = BlackStack::LocalLogger.new('parse.log')

l.log BlackStack::OpenAIScraper::NAME.green

l.logs "Initializing... "
BlackStack::OpenAIScraper.init
l.logf "done".green

while true
    prompt = nil
    print "#{BlackStack::OpenAIScraper::PROMPT}> ".blue
    s = gets.chomp
    begin
        # `\q` to quit
        if s == '\q'
            exit(0)
        # `\h` for help
        elsif s == '\h'
            puts BlackStack::OpenAIScraper.help 
            next
        # \wl <url>: download the web-page and pass the list of links to the model for further reference.\n
        elsif s.start_with?('\wl')
            # get the first parameter after \wl
            url = s.split(' ')[1]
            prompt = BlackStack::OpenAIScraper.wl(url)
            puts prompt.blue
        # \wt <url>: download the web-page and pass the text content to the model for further reference.\n 
        elsif s.start_with?('\wt')
            raise 'Not implemented yet'
        else 
            prompt = s
        end

        # standard openai prompt
        puts BlackStack::OpenAIScraper.response(prompt).to_s.green

    rescue SignalException, SystemExit, Interrupt => e
        puts 'Bye!'
        exit(0)
    rescue => e
        puts "Error: #{e.message.red}".red
    end
end

exit(0)

