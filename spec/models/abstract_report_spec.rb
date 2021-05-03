include GrafanaReporter

describe AbstractReport do
  subject { AbstractReport.new(Configuration.new) }

  it 'has abstract methods' do
    expect { subject.progress }.to raise_error(NotImplementedError)
    expect { subject.class.demo_report_classes }.to raise_error(NotImplementedError)
  end
end
