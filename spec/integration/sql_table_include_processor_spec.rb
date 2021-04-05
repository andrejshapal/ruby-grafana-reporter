include GrafanaReporter::Asciidoctor::Extensions

describe SqlTableIncludeProcessor do
  before do
    config = Configuration.new
    config.logger.level = ::Logger::Severity::WARN
    config.config = { 'grafana' => { 'default' => { 'host' => STUBS[:url], 'api_key' => STUBS[:key_admin] } } }
    report = Report.new(config, './spec/tests/demo_report.adoc')
    Asciidoctor::Extensions.unregister_all
    Asciidoctor::Extensions.register do
      include_processor SqlTableIncludeProcessor.new.current_report(report)
    end
    @report = report
  end

  it 'can be processed' do
    expect(@report.logger).not_to receive(:error)
    expect(Asciidoctor.convert("include::grafana_sql_table:#{STUBS[:datasource_sql]}[sql=\"SELECT 1\"]", to_file: false)).not_to include('GrafanaReporterError')
  end

  it 'can translate times' do
    @report.logger.level = ::Logger::Severity::DEBUG
    expect(@report.logger).to receive(:debug).exactly(4).times.with(any_args)
    expect(@report.logger).to receive(:debug).with(/"from":"#{Time.utc(Time.new.year,1,1).to_i * 1000}".*"to":"#{(Time.utc(Time.new.year + 1,1,1) - 1).to_i * 1000}"/)
    expect(@report.logger).to receive(:debug).with(/Received response/)
    expect(Asciidoctor.convert("include::grafana_sql_table:#{STUBS[:datasource_sql]}[sql=\"SELECT 1\",from_timezone=\"UTC\",to_timezone=\"UTC\",from=\"now/y\",to=\"now/y\"]", to_file: false)).not_to include('GrafanaReporterError')
  end

  it 'shows fatal error if sql statement is missing' do
    expect(@report.logger).to receive(:fatal).with('GrafanaError: No SQL statement has been specified. (Grafana::MissingSqlQueryError)')
    expect(Asciidoctor.convert("include::grafana_sql_table:#{STUBS[:datasource_sql]}[from=\"now/y\",to=\"now/y\"]", to_file: false)).to include('|GrafanaError: No SQL statement has been specified. (Grafana::MissingSqlQueryError)')
  end

  it 'shows error if a reporter error occurs' do
    expect(@report.logger).to receive(:error).with('GrafanaReporterError: The specified time range \'schwurbel\' is unknown.')
    expect(Asciidoctor.convert("include::grafana_sql_table:#{STUBS[:datasource_sql]}[sql=\"SELECT 1\",from=\"schwurbel\",to=\"now/y\"]", to_file: false)).to include('|GrafanaReporterError: The specified time range \'schwurbel\' is unknown.')
  end

end
