module GrafanaReporter
  module Asciidoctor
    module Extensions
      # Implements the hook
      #   include::grafana_help[]
      #
      # Shows all available options for the asciidoctor grafana reporter in a asciidoctor readable form.
      #
      # == Used document parameters
      # None
      class ShowHelpIncludeProcessor < ::Asciidoctor::Extensions::IncludeProcessor
        include ProcessorMixin

        # :nodoc:
        def handles?(target)
          target.start_with? 'grafana_help'
        end

        # :nodoc:
        def process(_doc, reader, _target, _attrs)
          # return if @report.cancel
          @report.next_step
          @report.logger.debug('Processing ShowHelpIncludeProcessor')

          reader.unshift_lines Asciidoctor::Help.new.asciidoctor.split("\n")
        end
      end
    end
  end
end
