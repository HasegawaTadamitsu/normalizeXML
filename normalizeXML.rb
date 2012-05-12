require "optparse"
require "rexml/document"
require "rexml/parsers/pullparser" 
require "pry"

option = Hash.new
opts = OptionParser.new
option[:trim_flag]=true
opts.on '-f f','--file','input filename' do |v|
  option[:filename] = v
end

opts.on '-t','--trimoff','trim off' do |v|
  option[:trim_flag] = false
end

if ARGV[0].nil?
  puts "need argment:"
  puts opts.help
  exit 1
end

begin
  opts.parse!(ARGV)
rescue =>ex
  puts ex
  puts opts.help
  exit 1
end

if option[:filename].nil?
  puts "need filename option "
  puts opts.help
  exit 1
end

# parser = REXML::Parsers::PullParser.new File.new option[:filename] 
# while parser.has_next?
#  res = parser.pull
#  if res.event_type == :text 
#     text = "foo" #mytrim res[0]
#  end
#  binding.pry
#  p res
#end

def trim_text inp
  inp.gsub( "\n","").strip
end

def swap_text elements, trim
  elements.each do |element|
    unless element.parent?
#      binding.pry
      set_val = element.value
      set_val = trim_text(set_val) if trim
      element.value = set_val
    else 
      swap_text element, trim
    end
  end
end

doc = REXML::Document.new File.new option[:filename] 
swap_text doc.root, option[:trim_flag]

doc.write $stdout,2,true



