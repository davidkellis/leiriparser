require 'treetop'
require 'leirigrammar'

# Legacy Extended Internationalized Resource Identifiers (IRIs) - LEIRIs
class LegacyExtendedIRI
  attr_accessor :iri
  attr_accessor :scheme
  attr_accessor :userinfo
  attr_accessor :host
  attr_accessor :port
  attr_accessor :path
  attr_accessor :query
  attr_accessor :fragment
  attr_accessor :registry     # not sure what this is - not used
  attr_accessor :opaque       # not sure what this is - not used
  attr_accessor :reference_type
  
  def initialize(iri)
    @iri = iri
    parser = LEIRIParser.new
    parse_tree_root = parser.parse(iri)
    parse_tree_root.populate(self)
    @reference_type = parse_tree_root.reference_type()
  end
  
  def to_s
    fields = ["iri", "scheme", "userinfo", "host", "port", "path", "query", "fragment", "registry", "opaque", "reference_type"]
    fields.map {|f| "#{f}: #{self.send(f)}" }.join("\n")
  end
  
  def absolute?
    reference_type == :absolute
  end
  
  def relative?
    reference_type == :relative
  end
end

def main
  # iri = LegacyExtendedIRI.new("http://www.google.com:80/search?hl=en&q=leiri&aq=f&aqi=g10&aql=&oq=&gs_rfai=")
  iri = LegacyExtendedIRI.new("https://username:password@example.com:8042/over/there/index.dtb?type=animal;name=ferret#nose")
  puts iri.to_s
end

main if $0 == __FILE__