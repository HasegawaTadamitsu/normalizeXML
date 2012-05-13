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

describe "optionに関して" do

  it "-f example.xml と正常な場合" do
    noarg = NormalizeXML.new ['-f','example.xml']
    noarg.checkOption.should be_true
    opt = noarg.instance_eval{ @option }
    opt[:filename].should == 'example.xml'
    opt[:trim_flag].should be_true
  end

  it "-f example.xml -t と正常な時" do
    noarg = NormalizeXML.new ['-f','example.xml','-t']
    noarg.checkOption.should be_true
    opt = noarg.instance_eval{ @option }
    opt[:filename].should == 'example.xml'
    opt[:trim_flag].should be_false
  end

  it "オプションが無いとき" do
    noarg = NormalizeXML.new []
    noarg.checkOption.should be_false
  end

  it "意図しないオプションが指定されたとき" do
    noarg = NormalizeXML.new ['-aa']
    noarg.checkOption.should be_false
  end

end

describe "normalizeに関して" do
input=<<EOF
<?xml version="1.0" encoding="UTF-8"?> 
<hello>
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
><foo
  >aaaaaaaaaaaaaa日本語<child
    >childdata,childdata,childdata,childdata,childdata.</child
    ></foo
  ></hello
>
EOF
  it "実行例"  do
    doc = REXML::Document.new input
    normalize = NormalizeXML.new []
    normalize.swap_text doc.root, true
    output=""
    doc.write output, 2, true
    collect.should == output
  end
end

describe "trim_textに関して" do
  it "実行例"  do
    normalize = NormalizeXML.new []
    inp =" a b c "
    out = normalize.trim_text inp
    out.should == "abc"
  end

  it "改行を含む場合"  do
    normalize = NormalizeXML.new []
    inp =" a b c \na"
    out = normalize.trim_text inp
    out.should == "abca"
  end

end
