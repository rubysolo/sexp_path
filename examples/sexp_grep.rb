require 'rubygems'
require File.dirname(__FILE__) + '/../lib/sexp_path'
require 'ruby_parser'

# Example program, this will scan a file for anything
# matching the Sexp passed in.


pattern = ARGV.shift
paths = ARGV

if paths.empty? || !pattern
  puts "Prints classes and methods in a file"
  puts "usage:"
  puts "  ruby sexp_grep.rb <pattern> <path>"
  puts "example:"
  puts "  ruby sexp_grep.rb 't(:defn)' *.rb"
  exit
end

begin
  # Generate the pattern, we use a little instance_eval trickery here. 
  pattern = SexpPath::SexpQueryBuilder.instance_eval(pattern)
rescue Exception=>ex
  puts "Invalid Pattern: '#{pattern}'"
  puts "Trace:"
  puts ex
  puts ex.backtrace
  exit 1
end

# For each path the user defined, search for the SexpPath pattern
paths.each do |path|  
  # Parse it with RubyParser, and append line numbers
  sexp = RubyParser.new.parse(File.read(path), path)
  found = false
  
  # Search it with the given pattern, printing any results
  sexp.search_each(pattern) do |match|
    if !found
      puts path
      found = true
    end
    puts "%4i: %s" % [match.sexp.line, match.sexp.inspect]
  end
end