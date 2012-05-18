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

    opts.on '-d d','--dirname','dirname ' do |v|
      @option[:dirname] = v
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

    if @option[:filename].nil? and @option[:dirname].nil?
      puts "need filename or dirname option "
      puts opts.help
      return false
    end

    if (!@option[:filename].nil?) and(! @option[:dirname].nil?)
      puts "filename or dirname option "
      puts opts.help
      return false
    end

    return true
   end

   def createNormalizeXMLFilename filename
     File.basename(filename,".xml") + ".normalizedXML"
   end

   def normalizeFilename filename
     newFilename= createNormalizeXMLFilename filename
     doc = REXML::Document.new File.new filename
     swap_text doc.root, @option[:trim_flag]
     File.open(newFilename,"w") do |f|
       doc.write f,2,true
     end
   end

   def getXMLFiles dirname
     ret.concat Dir::glob dir + "/**/*.[xX][mM][lL]"
   end

   def normalizeDir dirname
     files = getXMLFiles dirname
     files.each do |file|
       normalizeFilename  file
     end
   end

   def normalize
     unless @option[:filename].nil?
       normalizeFilename @option[:filename]
       return
     end
     normalizeDir @option[:dirnmae]
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
