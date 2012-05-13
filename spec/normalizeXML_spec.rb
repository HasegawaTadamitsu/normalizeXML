# -*- coding: utf-8 -*-
require 'rspec'

#require './normalizeXML'

describe "notmalizeXML" do
  before do
    @argv = ['-x', '320',
             '-yscale', '240',
             '-m', 'hello world',
             '-h', 
             '--output', '/path/to/output/',
             '-debug']
    @parser = ArgsParser.parser
    @parser.bind(:message, :m, "message text")
    @parser.bind(:output, :o, "path to output directory")
    @parser.comment(:debug, "debug mode")
    @parser.bind(:help, :h, "show help")
    @parser.bind(:xscale, :x, "width")
    @parser.bind(:yscale, :y, "height")
    @params = @parser.parse(@argv)
  end

  it "has param" do
    @parser.has_param(:message).should == true
    @parser.has_param(:output).should == true
  end

end
