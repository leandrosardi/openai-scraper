require_relative '../lib/openai-scraper.rb'
require_relative '../config.rb'

filename = './hgwarchitecture.html'
l = BlackStack::LocalLogger.new('console.log')

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
        elsif s =~ /\\wl/
            # find the url after the `\wl`, when \wl may be at any position into the string
            prompt = s
            i = 0
            s.split(' ').each { |x|
                if x == '\wl'
                    url = s.split(' ')[i+1]
                    prompt.gsub!(/\\wl #{url}/, BlackStack::OpenAIScraper.wl(url).to_s)
                end
                i += 1
            }
            puts BlackStack::OpenAIScraper::HINT1
            puts prompt.blue
        # \wt <url>: download the web-page and pass the text content to the model for further reference.\n 
        elsif s.start_with?('\wt')
            raise 'Not implemented yet'
        else 
            prompt = s
        end
binding.pry
        # standard openai prompt
        puts BlackStack::OpenAIScraper.response(prompt).to_s.green

    rescue SignalException, SystemExit, Interrupt => e
        l.logs "Finalizing... "
        BlackStack::OpenAIScraper.finalize
        l.logf "done".green

        l.log 'Bye!'
        exit(0)
    rescue => e
        puts "Error: #{e.to_console.red}".red
    end
end

exit(0)

