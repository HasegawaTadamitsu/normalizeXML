require "optparse"
require "rexml/document"
#require "rexml/parsers/pullparser" 
#require "pry"

class NormalizeXML

  def initialize trim_flg
   @trim_flg = trim_flg
  end

  def executeWithFile inputFileName
    doc = REXML::Document.new File.new inputFileName
    swap_text doc.root
    outputFileName = createNormalizeXMLFilename inputFileName
    File.open( outputFileName,"w") do |f|
      doc.write f, 2, true
    end
  end

  def executeWithDir dirname
    files = getXMLFiles dirname
    files.each do |file|
      executeWithFile  file
    end
  end

  private
  def trim_text inp
    inp.gsub( "\n","").gsub(" ","").gsub("\t","")
  end

  def swap_text elements
    elements.each do |element|
      if element.respond_to? :value
        set_val = element.value
        set_val = trim_text(set_val) if @trin_flg
        element.value = set_val
      end
      if element.parent?
        swap_text element
      end
    end
  end

  def createNormalizeXMLFilename filename
    dir = File.dirname filename
    file = File.basename(filename,".xml") + ".normalizedXML"
    File.join(dir,file)
  end

  def getXMLFiles dirname
    Dir::glob dirname + "/**/*.[xX][mM][lL]"
  end

end

class Main

  def initialize args
    @args = args
    @option = Hash.new
    @option[:trim_flag]=true
  end

  def execute
    exit 1 unless  checkOption
    normalizeXML = NormalizeXML.new @option[:trim_flg]
    unless @option[:filename].nil?
      normalizeXML.executeWithFile @option[:filename]
      return
    end
    normalizeXML.executeWithDir @option[:dirname]
   return
  end

  private
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

end

main = Main.new ARGV
main.execute

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
