module Oga
  module XML
    ##
    # Class used for storing information about an entire XML document. This
    # includes the doctype, XML declaration, child nodes and more.
    #
    # @!attribute [rw] doctype
    #  The doctype of the document.
    #  @return [Oga::XML::Doctype]
    #
    # @!attribute [rw] xml_declaration
    #  The XML declaration of the document.
    #  @return [Oga::XML::XmlDeclaration]
    #
    class Document
      attr_accessor :doctype, :xml_declaration

      ##
      # @param [Hash] options
      #
      # @option options [Oga::XML::NodeSet] :children
      # @option options [Oga::XML::Doctype] :doctype
      # @option options [Oga::XML::XmlDeclaration] :xml_declaration
      #
      def initialize(options = {})
        @doctype         = options[:doctype]
        @xml_declaration = options[:xml_declaration]

        self.children = options[:children] if options[:children]
      end

      ##
      # @return [Oga::XML::NodeSet]
      #
      def children
        return @children ||= NodeSet.new([], self)
      end

      ##
      # Sets the child nodes of the document.
      #
      # @param [Oga::XML::NodeSet|Array] nodes
      #
      def children=(nodes)
        if nodes.is_a?(NodeSet)
          @children = nodes
        else
          @children = NodeSet.new(nodes, self)
        end
      end

      ##
      # Returns a NodeSet containing *all* the nodes in the current document.
      # Nodes are inserted in the order they appear in the document.
      #
      # This method uses a breadth first search for tree traversal. See
      # http://en.wikipedia.org/wiki/Breadth-first_search for more information.
      #
      # THINK: Turn into an actual search instead of returning everything?
      #
      # @return [Oga::XML::NodeSet]
      #
      def all_nodes
        nodes = NodeSet.new
        visit = children.to_a.dup # copy it since we're using #pop below.

        until visit.empty?
          current = visit.pop

          nodes << current

          current.children.each do |child|
            visit << child
          end
        end

        return nodes
      end

      ##
      # Converts the document and its child nodes to XML.
      #
      # @return [String]
      #
      def to_xml
        xml = children.map(&:to_xml).join('')

        if doctype
          xml = doctype.to_xml + "\n" + xml.strip
        end

        if xml_declaration
          xml = xml_declaration.to_xml + "\n" + xml.strip
        end

        return xml
      end

      ##
      # Inspects the document and its child nodes. Child nodes are indented for
      # each nesting level.
      #
      # @return [String]
      #
      def inspect
        class_name  = self.class.to_s.split('::').last
        child_lines = children.map { |child| child.inspect(4) }.join("\n")

        if doctype
          dtd = doctype.inspect(2)
        else
          dtd = doctype.inspect
        end

        if xml_declaration
          decl = xml_declaration.inspect(2)
        else
          decl = xml_declaration.inspect
        end

        return <<-EOF.strip
#{class_name}(
  doctype: #{dtd}
  xml_declaration: #{decl}
  children: [
#{child_lines}
])
        EOF
      end
    end # Document
  end # XML
end # Oga
