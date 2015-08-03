require 'virtus'
require 'axe/api/results/checked_node'

module Axe
  module API
    class ValueObject
      include Virtus.value_object
    end

    class Results
      include Virtus.value_object

      class Rule < ValueObject
        values do
          attribute :id, Symbol
          attribute :description, String
          attribute :help, String
          attribute :helpUrl, String
          attribute :impact, Symbol
          attribute :tags, Array[Symbol]
          attribute :nodes, Array[CheckedNode]
        end

        def failure_message(index)
          <<-MSG
          #{index+1}) #{help}: #{helpUrl}
          #{nodes.map(&:failure_message).join("\n")}
          MSG
        end
      end

      values do
        attribute :url
        attribute :timestamp
        attribute :passes, Array[Rule]
        attribute :violations, Array[Rule]
      end

      attr_accessor :invocation

      def passed?
        violations.count == 0
      end

      def failure_message
        if passed?
          <<-MSG.gsub(/^\s*/,'')
          Expected to find accessibility violations. None were detected.
          Invocation: #{invocation}
          MSG
        else
          <<-MSG.gsub(/^\s*/,'')
          Found #{violations.count} accessibility #{violations.count == 1 ? 'violation' : 'violations'}
          Invocation: #{invocation}
          #{ violations.each_with_index.map(&:failure_message).join("\n\n") }
          MSG
        end
      end
    end
  end
end
