# -*- coding: utf-8 -*-

require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start

require 'rspec'

begin
  require File.join(File.dirname(__FILE__), '../normalizeXML.rb')
rescue SystemExit
end

describe "Mainに関して" do

  it "-f example.xml と正常な場合" do
    main = Main.new ['-f','example.xml']
    (main.__send__ :checkOption ).should be_true
    opt = main.instance_eval{ @option }
    opt[:trim_flag].should be_true
  end

  it "-d dir と正常な場合" do
    main = Main.new ['-d','./']
    (main.__send__ :checkOption ).should be_true
    opt = main.instance_eval{ @option }
    opt[:trim_flag].should be_true
  end

  it "-t をつけた場合の振る舞い" do
    main = Main.new ['-t']
    (main.__send__ :checkOption).should be_false
    opt = main.instance_eval{ @option }
    opt[:trim_flag].should be_false
  end

  it "-f -d をつけた場合の振る舞い" do
    main = Main.new ['-f','-d']
    (main.__send__ :checkOption).should be_true
    opt = main.instance_eval{ @option }
    opt[:filename].should == '-d'
  end

  it "-f a -d をつけた場合の振る舞い" do
    main = Main.new ['-f','a','-d','b']
    (main.__send__ :checkOption).should be_false
    opt = main.instance_eval{ @option }
    opt[:filename].should == 'a'
    opt[:dirname].should == 'b'
  end

  it "不正なオプションの振る舞い" do
    main = Main.new ['-xx']
    (main.__send__ :checkOption).should be_false
    opt = main.instance_eval{ @option }
    opt[:trim_flag].should be_true
  end

  it "optionなしの振る舞い" do
    main = Main.new []
    (main.__send__ :checkOption).should be_false
    opt = main.instance_eval{ @option }
    opt[:trim_flag].should be_true
  end

end

describe "NormalizeXMLに関して" do

  it "trimの確認" do
    xml = NormalizeXML.new true
    inp =" a b c "
    out = xml.__send__ :trim_text, inp
    out.should == "abc"
    inp =" a b c \na"
    out = xml.__send__ :trim_text, inp
    out.should == "abca"
    inp ="\t a b c \na"
    out = xml.__send__ :trim_text, inp
    out.should == "abca"
  end

input=<<EOF
<?xml version="1.0" encoding="UTF-8"?> 
<hello>
<!-- comment -->
 <foo>
  aaaaaaaaaaaaaa日本 語
 <child>
  childdata,
    childdata,
    childdata,
  childdata,
  childdata.
 </child>
 </foo>

</hello>
EOF
collect=<<EOF
<?xml version='1.0' encoding='UTF-8'?> 
<hello
><!-- comment --><foo
  >aaaaaaaaaaaaaa日本語<child
    >childdata,childdata,childdata,childdata,childdata.</child
    ></foo
  ></hello
>
EOF

  it "swap_txt"  do
    doc = REXML::Document.new input
    xml = NormalizeXML.new true
    xml.__send__( :swap_text, doc.root)
    output=""
    doc.write output, 2, true
#    collect.should == output
  end

  it "createNormalizeXMLFilename"  do
    xml = NormalizeXML.new true
    (xml.__send__ :createNormalizeXMLFilename, "abc" ).should == "./abc.normalizedXML"
    (xml.__send__ :createNormalizeXMLFilename, "abc.xml" ).should == "./abc.normalizedXML"
  end

  it "getXMLFiles"  do
    xml = NormalizeXML.new []
    ret = xml.__send__ :getXMLFiles, "./" 
    ret[0].should == ".//spec/example.xml"
  end

  it "実行例"  do
    main = Main.new ["-d","./"]
    main.execute
  end

  it "実行例"  do
    main = Main.new ["-f","./spec/example.xml"]
    main.execute
  end
end
