require "optparse"
require "rexml/document"
#require "rexml/parsers/pullparser" 
#require "pry"

class NormalizeXML

  def trim_text inp
    inp.gsub( "\n","").gsub(" ","").gsub("\t","")
  end

  def swap_text elements, trim
    elements.each do |element|
      if element.respond_to? :value
        set_val = element.value
        set_val = trim_text(set_val) if trim 
        element.value = set_val
      end
      if element.parent?
#       binding.pry
        swap_text element, trim
      end
    end
  end

  def initialize args
    @args = args
    @option = Hash.new
    @option[:trim_flag]=true
  end

  def checkOption
    opts = OptionParser.new

    opts.on '-f f','--file','input filename' do |v|
      @option[:filename] = v
    end

    opts.on '-t','--trimoff','trim off' do |v|
      @option[:trim_flag] = false
    end

    if @args[0].nil?
      puts "need argment:"
      puts opts.help
      return false
    end

    begin
      opts.parse!(@args)
    rescue =>ex
      puts ex
      puts opts.help
      return false
    end

    if @option[:filename].nil?
      puts "need filename option "
      puts opts.help
      return false
    end
    return true
   end

   def normalize
     doc = REXML::Document.new File.new @option[:filename] 
     swap_text doc.root, @option[:trim_flag]
     doc.write $stdout,2,true
   end
end

normalizeXML = NormalizeXML.new ARGV
exit 1 unless normalizeXML.checkOption
normalizeXML.normalize

#memo
#
# parser = REXML::Parsers::PullParser.new File.new option[:filename] 
# while parser.has_next?
#  res = parser.pull
#  if res.event_type == :text 
#     text = "foo" #mytrim res[0]
#  end
#  binding.pry
#  p res
#end
