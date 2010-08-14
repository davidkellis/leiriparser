# encoding: utf-8

require 'test/unit'
require 'leiri'

def main
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
    
    rules.each do |rule|
      assert_not_nil(@parser.parse(rule), "Unable to parse: #{rule}")
    end
  end
  
  # This implements the test suite given in RFC 3986, Section 5.4
  def test_reference_resolution
    base_uri = LegacyExtendedIRI.new("http://a/b/c/d;p?q")
    relative_uris = ["g:h",
                     "g",
                     "./g",
                     "g/",
                     "/g",
                     "//g",
                     "?y",
                     "g?y",
                     "#s",
                     "g#s",
                     "g?y#s",
                     ";x",
                     "g;x",
                     "g;x?y#s",
                     "",
                     ".",
                     "./",
                     "..",
                     "../",
                     "../g",
                     "../..",
                     "../../",
                     "../../g",
                     "../../../g",
                     "../../../../g",
                     "/./g",
                     "/../g",
                     "g.",
                     ".g",
                     "g..",
                     "..g",
                     "./../g",
                     "./g/.",
                     "g/./h",
                     "g/../h",
                     "g;x=1/./y",
                     "g;x=1/../y",
                     "g?y/./x",
                     "g?y/../x",
                     "g#s/./x",
                     "g#s/../x",
                     "http:g"]
                     
                     
                     
                     
    resolved_uris = ["g:h",
                     "http://a/b/c/g",
                     "http://a/b/c/g",
                     "http://a/b/c/g/",
                     "http://a/g",
                     "http://g",
                     "http://a/b/c/d;p?y",
                     "http://a/b/c/g?y",
                     "http://a/b/c/d;p?q#s",
                     "http://a/b/c/g#s",
                     "http://a/b/c/g?y#s",
                     "http://a/b/c/;x",
                     "http://a/b/c/g;x",
                     "http://a/b/c/g;x?y#s",
                     "http://a/b/c/d;p?q",
                     "http://a/b/c/",
                     "http://a/b/c/",
                     "http://a/b/",
                     "http://a/b/",
                     "http://a/b/g",
                     "http://a/",
                     "http://a/",
                     "http://a/g",
                     "http://a/g",
                     "http://a/g",
                     "http://a/g",
                     "http://a/g",
                     "http://a/b/c/g.",
                     "http://a/b/c/.g",
                     "http://a/b/c/g..",
                     "http://a/b/c/..g",
                     "http://a/b/g",
                     "http://a/b/c/g/",
                     "http://a/b/c/g/h",
                     "http://a/b/c/h",
                     "http://a/b/c/g;x=1/y",
                     "http://a/b/c/y",
                     "http://a/b/c/g?y/./x",
                     "http://a/b/c/g?y/../x",
                     "http://a/b/c/g#s/./x",
                     "http://a/b/c/g#s/../x",
                     "http:g"]

    #puts base_uri
    relative_uris.zip(resolved_uris).each do |pair|
      #puts LegacyExtendedIRI.new(pair[0]),'---'
      assert_equal(pair[1], base_uri.transform_relative_reference(LegacyExtendedIRI.new(pair[0])).recompose)
    end
  end
end