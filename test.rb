# encoding: utf-8

require 'treetop'
require "test/unit"

def main
  Treetop.load "leirigrammar"
  
  parser = LEIRIParser.new
  node = parser.parse('http://www.yahoo.com/')
  if node
    puts 'valid syntax'
  else
    puts 'invalid syntax'
  end
end

#main

class TestRule < Test::Unit::TestCase
  def initialize(*args)
    super
    
    Treetop.load "leirigrammar"
    @parser = LEIRIParser.new
  end
  
  def test_valid_uris
    rules = ["http://www.yahoo.com/",
             "http://www.yahoo.com",
             "http://example.org/today/",
             "/hotpicks/",
             "http://example.org/wine/",
             "rosé"
            ]
    
    rules.all? do |rule|
      assert_not_nil(@parser.parse(rule), "Unable to parse: #{rule}")
    end
  end
end