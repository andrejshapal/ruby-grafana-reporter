# frozen_string_literal: true

require_relative 'sql_table_query'

module GrafanaReporter
  module Asciidoctor
    # (see SqlTableQuery)
    #
    # The SQL query as well as the datasource configuration are thereby captured from a
    # {Grafana::Panel}.
    class PanelTableQuery < SqlTableQuery
      include QueryMixin

      # @param panel [Grafana::Panel] panel which contains the query
      # @param query_letter [String] letter of the query within the panel, which shall be used, e.g. +C+
      def initialize(panel, query_letter)
        super(nil, nil)
        @panel = panel
        @query_letter = query_letter
        extract_dashboard_variables(@panel.dashboard)
      end

      # Retrieves the query and the configured datasource from the panel.
      # @see Grafana::AbstractSqlQuery#pre_process
      # @param grafana [Grafana::Grafana] grafana instance against which the query shall be executed
      # @return [void]
      def pre_process(grafana)
        @sql = @panel.query(@query_letter)
        # resolve datasource name
        @datasource_name = @panel.field('datasource')
        @datasource = grafana.datasource_by_name(@datasource_name)
        super(grafana)
        @from = translate_date(@from, @variables['grafana-report-timestamp'], false, @variables['from_timezone'] ||
                               @variables['grafana_default_from_timezone'])
        @to = translate_date(@to, @variables['grafana-report-timestamp'], true, @variables['to_timezone'] ||
                             @variables['grafana_default_to_timezone'])
      end

      # @see AbstractQuery#self.build_demo_entry
      def self.build_demo_entry(panel)
        return nil unless panel
        return nil unless panel.model['type'].include?('table')

        ref_id = nil
        panel.model['targets'].each do |item|
          if !item['hide'] && !panel.query(item['refId']).to_s.empty?
            ref_id = item['refId']
            break
          end
        end
        return nil unless ref_id

        "|===\ninclude::grafana_panel_query_table:#{panel.id}[query=\"#{ref_id}\",filter_columns=\"time\","\
        "dashboard=\"#{panel.dashboard.id}\"]\n|==="
      end
    end
  end
end
