include GrafanaReporter::Asciidoctor

describe PanelQueryTableIncludeProcessor do
  before do
    config = Configuration.new
    config.logger.level = ::Logger::Severity::WARN
    config.config = { 'grafana' => { 'default' => { 'host' => STUBS[:url], 'api_key' => STUBS[:key_admin]} } }
    report = Report.new(config)
    Asciidoctor::Extensions.unregister_all
    Asciidoctor::Extensions.register do
      include_processor PanelQueryTableIncludeProcessor.new.current_report(report)
    end
    @report = report
  end

  context 'sql table' do
    it 'can return full results' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\"]", to_file: false)).not_to include('GrafanaReporterError')
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\"]", to_file: false)).to match(/<p>\| 1594308060000 \| 43.9/)
    end

    it 'can translate times' do
      @report.logger.level = ::Logger::Severity::DEBUG
      expect(@report.logger).to receive(:debug).exactly(5).times.with(any_args)
      expect(@report.logger).to receive(:debug).with(/"from":"#{Time.utc(Time.new.year,1,1).to_i * 1000}".*"to":"#{(Time.utc(Time.new.year + 1,1,1) - 1).to_i * 1000}"/)
      expect(@report.logger).to receive(:debug).with(/Received response/)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",from_timezone=\"UTC\",to_timezone=\"UTC\",dashboard=\"#{STUBS[:dashboard]}\",from=\"now/y\",to=\"now/y\"]", to_file: false)).not_to include('GrafanaReporterError')
    end

    it 'can replace values' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",replace_values_1=\"1594308060000:geht\"]", to_file: false)).to match(/<p>\| geht \| 43.9/)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",replace_values_2=\"1594308060000:geht\"]", to_file: false)).to match(/<p>\| 1594308060000 \| 43.9/)
    end

    it 'can handle escaped replace values' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",replace_values_1=\"1594308060000:geht\\:mit\\:doppel doppelpunkt\"]", to_file: false)).to match(/<p>\| geht:mit:doppel doppelpunkt \| 43.9/)
    end

    it 'can replace regex values' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",format=\",%.2f\",filter_columns=\"time_sec\",replace_values_2=\"^(43)\..*$:geht - \\1\"]", to_file: false)).to include('| geht - 43').and include('| 44.00')
    end

    it 'can handle malformed regex values' do
      expect(@report.logger).to receive(:error).at_least(:once)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",replace_values_2=\"^(43\..*$:geht - \\1\"]", to_file: false)).to include('| end pattern with unmatched parenthesis')
    end

    it 'can replace values with value comparison' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",format=\",%.2f\",filter_columns=\"time_sec\",replace_values_2=\"<44:geht\"]", to_file: false)).to include('| geht').and include('| 44.00')
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",format=\",%.2f\",filter_columns=\"time_sec\",replace_values_2=\"<44:\\1 zu klein\"]", to_file: false)).to include('| 43.90 zu klein').and include('| 44.00')
    end

    it 'can filter columns' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",filter_columns=\"time_sec\"]", to_file: false)).to match(/<p>\| 43.9/)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",filter_columns=\"Warmwasser\"]", to_file: false)).to match(/<p>\| 1594308060000\n/)
    end

    it 'can format values' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",format=\",%.2f\"]", to_file: false)).to match(/<p>\| 1594308060000 \| 43.90/)
    end

    it 'handles column and row divider in deprecated table formatter' do
      expect(@report.logger).not_to receive(:error)
      expect_any_instance_of(GrafanaReporter::Logger::TwoWayDelegateLogger).to receive(:warn).with(/You are using deprecated 'table_formatter' named 'adoc_deprecated'/)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",column_divider=\" col \",row_divider=\"row \",table_formatter=\"adoc_deprecated\"]", to_file: false)).to match(/<p>row 1594308060000 col 43.9/)
    end

    # TODO: properly add headline on transposed results
    it 'can include headline' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",include_headline=\"true\"]", to_file: false)).to match(/<p>\| time_sec \| Warmwasser\n/)
    end

    it 'can transpose results' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",transpose=\"true\"]", to_file: false)).to match(/<p>\| 1594308060000 \| 1594308030000 \|/)
    end

    it 'handles grafana errors' do
      expect(@report.logger).to receive(:error).with('GrafanaError: The specified panel id \'99\' does not exist on the dashboard \'IDBRfjSmz\'. (Grafana::PanelDoesNotExistError)')
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_does_not_exist][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\"]", to_file: false)).to include('|GrafanaError: The specified panel id \'99\' does not exist on the dashboard \'IDBRfjSmz\'. (Grafana::PanelDoesNotExistError)')
    end

    it 'shows error if a reporter error occurs' do
      expect(@report.logger).to receive(:error).with('GrafanaReporterError: The specified time range \'schwurbel\' is unknown.')
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_sql][:id]}[query=\"#{STUBS[:panel_sql][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",from=\"schwurbel\"]", to_file: false)).to include('|GrafanaReporterError: The specified time range \'schwurbel\' is unknown.')
    end

    it 'handles standard error on internal fault' do
      obj = PanelQueryTableIncludeProcessor.new.current_report(@report)
      class MyReader; def unshift_line(*args); end; end
      expect(@report.logger).to receive(:fatal).with('undefined method `attributes\' for nil:NilClass')
      obj.process(nil, MyReader.new, ":#{STUBS[:panel_sql][:id]}", { 'instance' => 'default', 'dashboard' => STUBS[:dashboard] })
    end
  end

  context 'unknown datasource' do
    it 'returns error on unknown datasource requests' do
      expect(@report.logger).to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_ds_unknown][:id]}[query=\"A\",dashboard=\"#{STUBS[:dashboard]}\",from=\"0\",to=\"0\"]", to_file: false)).to include('Error')
    end
  end

  context 'graphite' do
    it 'can handle graphite requests' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_graphite][:id]}[query=\"#{STUBS[:panel_graphite][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",from=\"0\",to=\"0\"]", to_file: false)).to match(/<p>| 1621773300000 | 265 | 274 | 265 | 255\n\|/)
    end
  end

  context 'prometheus' do
    it 'can handle prometheus requests' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_prometheus][:id]}[query=\"#{STUBS[:panel_prometheus][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",from=\"0\",to=\"0\"]", to_file: false)).to match(/<p>\| 1617728730 \|  \|  \|  \| 0.011986814503580401 \| 0.6412945761450544\n\|/)
    end
  end

  context 'influx' do
    it 'can handle influx requests' do
      expect(@report.logger).not_to receive(:error)
      expect(Asciidoctor.convert("include::grafana_panel_query_table:#{STUBS[:panel_influx][:id]}[query=\"#{STUBS[:panel_influx][:letter]}\",dashboard=\"#{STUBS[:dashboard]}\",from=\"0\",to=\"0\"]", to_file: false)).to include("<p>\| 1621781110000 \| 4410823132.66179 \| 3918217168.1713953 \| 696149370.0246137 \| 308698357.77230036 \|  \| 2069259154.5448523 \| 1037231406.781757 \| 2008807302.9000952 \| 454762299.1667595 \| 1096524688.048703\n\|")
    end
  end
end
