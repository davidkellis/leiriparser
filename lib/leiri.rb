require 'treetop'
require 'leirigrammar'    # This is a TreeTop generated file
require 'xpointer'
require 'open-uri'        # for URI.parse

# Algorithm given in RFC 3986 Section 5.2.4.
def remove_dot_segments(path)
  input = path
  output = ""
  # puts output, input, "---"
  until input.empty?
    if m=input.match(/^((\.\.\/)|(\.\/))/)            # match "../" or "./"
      input = m.post_match
    elsif m=input.match(/^((\/\.\/)|(\/\.$))/)         # match "/./" or "/.", where "." is a ***complete path segment***
      input = "/" + m.post_match
    elsif m=input.match(/^((\/\.\.\/)|(\/\.\.$))/)     # match "/../" or "/..", where "." is a ***complete path segment***
      input = "/" + m.post_match
      last_slash = output.rindex('/')
      if last_slash
        output = output[0, last_slash]
      else
        output = ""
      end
    elsif input == "." || input == ".."               # match "." or ".."
      input = ""
    else
      i = if input.start_with?('/')
        input.index('/', 1)
      else
        input.index('/')
      end
      
      if i
        output << input[0, i]
        input = input[i, input.length - i]
      else
        output << input
        input = ""
      end
    end
    # puts output, input, "---"
  end
  output
end

# Algorithm given in RFC 3986 Section 5.2.3
def merge_paths(base_leiri, relative_leiri)
  if base_leiri.authority && base_leiri.path.empty?
    "/#{relative_leiri.path}"
  else
    last_slash_index = base_leiri.path.rindex('/')
    base_path_excluding_last_segment = base_leiri.path[0..last_slash_index] if last_slash_index
    "#{base_path_excluding_last_segment}#{relative_leiri.path}"
  end
end

# Legacy Extended Internationalized Resource Identifiers (IRIs) - LEIRIs
class LegacyExtendedIRI
  URI = Struct.new(:scheme, :authority, :path, :query, :fragment)
  class URI
    # Implements RFC 3986, Section 5.3: "Component Recomposition"
    def to_s(include_fragment = true)
      result = ""

      if scheme
        result << scheme
        result << ":"
      end

      if authority
        result << '//'
        result << authority
      end

      result << path

      if query
        result << '?'
        result << query
      end

      if fragment && include_fragment
        result << '#'
        result << fragment
      end

      result
    end
  end
  
  attr_accessor :iri
  attr_accessor :scheme
  
  attr_accessor :authority    # this is composed of userinfo@host:port
  attr_accessor :userinfo
  attr_accessor :host
  attr_accessor :port
  
  attr_accessor :path
  attr_accessor :query
  attr_accessor :fragment
  
  # this is not a component of the URI; it's a flag that tells me which grammar rule was followed: "leiri" or "irelative_ref"
  attr_accessor :reference_type
  
  def initialize(iri)
    @iri = iri.to_s
    parser = LEIRIParser.new
    parse_tree_root = parser.parse(@iri)
    parse_tree_root.populate(self)
  end
  
  def to_debug_string
    fields = ["iri", "scheme", "authority", "userinfo", "host", "port", "path", "query", "fragment", "reference_type"]
    fields.map {|f| "#{f}: #{self.send(f)}" }.join("\n")
  end
  
  # Implements RFC 3986, Section 5.3: "Component Recomposition"
  def to_s(include_fragment = true)
    result = ""
    
    if scheme
      result << scheme
      result << ":"
    end
    
    if authority
      result << '//'
      result << authority
    end
    
    result << path
    
    if query
      result << '?'
      result << query
    end
    
    if fragment && include_fragment
      result << '#'
      result << fragment
    end
    
    result
  end
  
  def absolute?
    reference_type == :absolute
  end
  
  def relative?
    reference_type == :relative
  end
  
  # Transforms a relative reference URI (represented by 'self') to its target URI, given a base URI (argument).
  #
  # This method implements the Relative URI Resolution algorithm presented RFC 3986 Section 5 (http://www.ietf.org/rfc/rfc3986.txt).
  # Section 5.2 is where the relative resolution algorithm is documented.
  #
  # This method assumes that 'self' is a relative URI and base_leiri is an absolute URI.
  #
  # Returns a new LEIRI representing the target (relatively-resolved) URI.
  def to_target(base_leiri)
    r = self
    base = base_leiri
    t = URI.new
    
    if r.scheme
      t.scheme = r.scheme
      t.authority = r.authority
      t.path = remove_dot_segments(r.path)
      t.query = r.query
    else
      if r.authority
        t.authority = r.authority
        t.path = remove_dot_segments(r.path)
        t.query = r.query
      else
        if r.path == ""
          t.path = base.path
          if r.query
            t.query = r.query
          else
            t.query = base.query
          end
        else
          if r.path.start_with?('/')
            t.path = remove_dot_segments(r.path)
          else
            t.path = merge_paths(base, r)
            t.path = remove_dot_segments(t.path)
          end
          t.query = r.query
        end
        t.authority = base.authority
      end
      t.scheme = base.scheme
    end
    
    t.fragment = r.fragment
    
    LegacyExtendedIRI.new(t.to_s)
  end
  
  # Transforms the given relative reference URI (argument) to its target URI, using 'self' as the base URI.
  #
  # This methods assumes 'self' represents the base URI and that the argument represents the relative reference URI.
  #
  # Returns a new LEIRI representing the target (relatively-resolved) URI.
  def transform_relative_reference(relative_reference_leiri)
    relative_reference_leiri.to_target(self)
  end
  
  def fragment_to_xpointer
    XPointer.new(fragment) if fragment
  end
  
  # Returns an object that is capable of reading a stream from the given IRI
  def open
    case scheme
    when /https|http|ftp/
      ::URI.parse(to_s).open
    when /file/
      File.open(to_s, "r")
    else
      File.open(to_s, "r")
    end
  end
  
  # Open the stream pointed to by this IRI, read from it, then close it.
  # Returns a string.
  def read
    stream = open()
    str = stream.read
    stream.close
    str
  end
end

def main
  # iri = LegacyExtendedIRI.new("http://www.google.com:80/search?hl=en&q=leiri&aq=f&aqi=g10&aql=&oq=&gs_rfai=")
  # iri = LegacyExtendedIRI.new("https://username:password@example.com:8042/over/there/index.dtb?type=animal;name=ferret#nose")
  # puts iri.to_s
  # puts remove_dot_segments("/a/b/c/./../../g")
  # puts remove_dot_segments("mid/content=5/../6")
end

main if $0 == __FILE__