# puts "RUBY_DESCRIPTION: #{RUBY_DESCRIPTION}\n\n" 

rubyVersionFile = File.dirname(__FILE__) + "/" + ".ruby-version"
if File.exist?rubyVersionFile
  file = File.new(rubyVersionFile, "r")
  while (line = file.gets)
      puts "rbenv local (this folder) as stated in .ruby-version: #{line}\n"
      puts "Look in the upper right corner of this window in TextMate to see what version TextMate is running. \nAlthough it may be running the version shown by this script.\n"
  end
  file.close
  puts "path to this file: #{File.dirname(__FILE__)}"
else
  puts "RUBY_DESCRIPTION: #{RUBY_DESCRIPTION}. Global rbenv since no .ruby-version file"
end
puts "\nENV[\"RBENV_VERSION\"]: #{ENV["RBENV_VERSION"]}. If not null, this setting controls the version run and \nwill show in the purple area.\n  Have to use TextMate's RBENV_VERSION since TextMate ignores rbenv settings."