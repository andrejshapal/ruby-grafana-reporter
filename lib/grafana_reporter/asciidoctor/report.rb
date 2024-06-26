# frozen_string_literal: true

module GrafanaReporter
  # This module contains all classes, which are necessary to use the reporter in conjunction with asciidoctor.
  module Asciidoctor
    # Implementation of a specific {AbstractReport}. It is used to
    # build reports specifically for asciidoctor results.
    class Report < ::GrafanaReporter::AbstractReport
      # @see AbstractReport#initialize
      def initialize(config)
        super
        @image_files = []
      end

      # Starts to create an asciidoctor report. It utilizes all extensions in the {GrafanaReporter::Asciidoctor}
      # namespace to realize the conversion.
      # @see AbstractReport#build
      def build
        attrs = { 'convert-backend' => 'pdf' }.merge(@config.default_document_attributes.merge(@custom_attributes))
        logger.debug("Document attributes: #{attrs}")

        initialize_step_counter

        # register necessary extensions for the current report
        ::Asciidoctor::LoggerManager.logger = logger

        registry = ::Asciidoctor::Extensions::Registry.new
        registry.inline_macro PanelImageInlineMacro.new.current_report(self)
        registry.inline_macro PanelQueryValueInlineMacro.new.current_report(self)
        registry.inline_macro PanelPropertyInlineMacro.new.current_report(self)
        registry.inline_macro SqlValueInlineMacro.new.current_report(self)
        registry.block_macro PanelImageBlockMacro.new.current_report(self)
        registry.include_processor ValueAsVariableIncludeProcessor.new.current_report(self)
        registry.include_processor PanelQueryTableIncludeProcessor.new.current_report(self)
        registry.include_processor SqlTableIncludeProcessor.new.current_report(self)
        registry.include_processor ShowEnvironmentIncludeProcessor.new.current_report(self)
        registry.include_processor ShowHelpIncludeProcessor.new.current_report(self)
        registry.include_processor AnnotationsTableIncludeProcessor.new.current_report(self)
        registry.include_processor AlertsTableIncludeProcessor.new.current_report(self)

        ::Asciidoctor.convert_file(@template, extension_registry: registry, backend: attrs['convert-backend'],
                                              to_file: path, attributes: attrs, header_footer: true)

        # store report including als images as ZIP file, if the result is not a PDF
        if attrs['convert-backend'] != 'pdf'
          zip_report(path, @config.reports_folder, attrs['convert-backend'], @config.images_folder, @image_files)
        end

        clean_image_files
      end

      # @see AbstractReport#default_template_extension
      def self.default_template_extension
        'adoc'
      end

      # @see AbstractReport#default_result_extension
      def self.default_result_extension
        'pdf'
      end

      # @see AbstractReport#demo_report_classes
      def self.demo_report_classes
        [AlertsTableIncludeProcessor, AnnotationsTableIncludeProcessor, PanelImageBlockMacro, PanelImageInlineMacro,
         PanelPropertyInlineMacro, PanelQueryTableIncludeProcessor, PanelQueryValueInlineMacro,
         SqlTableIncludeProcessor, SqlValueInlineMacro, ShowHelpIncludeProcessor, ShowEnvironmentIncludeProcessor]
      end

      private

      def initialize_step_counter
        @total_steps = 0
        File.readlines(@template).each do |line|
          begin
            # TODO: move these calls to the specific processors to ensure all are counted properly
            @total_steps += line.gsub(%r{//.*}, '').scan(/(?:grafana_panel_image|grafana_panel_query_value|
                                                         grafana_panel_query_table|grafana_sql_value|
                                                         grafana_sql_table|grafana_environment|grafana_help|
                                                         grafana_panel_property|grafana_annotations|grafana_alerts|
                                                         grafana_value_as_variable)/x).length
          rescue StandardError => e
            logger.error("Could not process line '#{line}' (Error: #{e.message})")
            raise e
          end
        end
        logger.debug("Template #{@template} contains #{@total_steps} calls of grafana reporter functions.")
      end
    end
  end
end
