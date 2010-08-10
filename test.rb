# encoding: utf-8

require 'treetop'

def main
  Treetop.load "leirigrammar"
  
  parser = LEIRIParser.new
  node = parser.parse('http://www.yahoo.com')
  if node
    puts 'valid syntax'
  else
    puts 'invalid syntax'
  end
end

main