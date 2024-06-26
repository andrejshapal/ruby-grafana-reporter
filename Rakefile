task default: [:test]

task :check do
  # fetch asciidoctor versions from docker file
  require 'net/http'
  uri = URI('https://raw.githubusercontent.com/asciidoctor/docker-asciidoctor/master/Dockerfile')
  html = Net::HTTP.get(uri)
  cur_asciidoctor_version = html.scan(/ARG asciidoctor_version=([\d.\w]+)/).flatten.first
  cur_asciidoctor_pdf_version = html.scan(/ARG asciidoctor_pdf_version=([\d.\w]+)/).flatten.first
  cur_asciidoctor_epub3_version = html.scan(/ARG asciidoctor_epub3_version=([\d.\w]+)/).flatten.first

  # read asciidoctor versions from gemspec
  gemspec = File.read('ruby-grafana-reporter.gemspec')
  expected_asciidoctor_version = gemspec.scan(/add_runtime_dependency 'asciidoctor', '~>([\d.\w]+)'/).flatten.first
  expected_asciidoctor_pdf_version = gemspec.scan(/add_runtime_dependency 'asciidoctor-pdf', '~>([\d.\w]+)'/).flatten.first
  expected_asciidoctor_epub3_version = gemspec.scan(/add_runtime_dependency 'asciidoctor-epub3', '~>([\d.\w]+)'/).flatten.first

  if cur_asciidoctor_version.start_with?(expected_asciidoctor_version) && cur_asciidoctor_pdf_version.start_with?(expected_asciidoctor_pdf_version) && cur_asciidoctor_epub3_version.start_with?(expected_asciidoctor_epub3_version)
    puts 'Current version dependencies PERFECTLY FIT to asciidoctor docker versions.'
  else
    puts 'Version dependencies in gemspec have to be adapted to docker versions:'
    puts " - asciidoctor: #{cur_asciidoctor_version}"
    puts " - asciidoctor-pdf: #{cur_asciidoctor_pdf_version}"
    puts " - asciidoctor-epub3: #{cur_asciidoctor_epub3_version}"
    exit 1
  end
end

task :build do
  Rake::Task['check'].invoke
  Rake::Task['preparebuild'].invoke
  Rake::Task['testsingle'].invoke
  Rake::Task['buildsingle'].invoke
  Rake::Task['buildgem'].invoke
end

task :buildgem do
  # read version information
  require_relative 'lib/VERSION'

  # build gem
  sh 'gem build ruby-grafana-reporter.gemspec'
end

task :preparebuild do
  # update date in version file
  version = File.read('lib/VERSION.rb')
  File.write('lib/VERSION.rb', version.gsub(/GRAFANA_REPORTER_RELEASE_DATE *= [^$\n]*/, "GRAFANA_REPORTER_RELEASE_DATE = '#{Time.now.to_s[0..9]}'"))

  require_relative 'lib/ruby_grafana_reporter'

  # update help documentation
  File.write('FUNCTION_CALLS.md', GrafanaReporter::Asciidoctor::Help.new.github)
end

task :buildsingle do
  # read version information
  require_relative 'lib/VERSION'

  # read version information
  require_relative 'bin/get_single_file_application'

  # build single file application
  File.write("ruby-grafana-reporter-#{GRAFANA_REPORTER_VERSION.join('.')}.rb", get_result('bin'))

  # run single file application to see it is running without issues
  ruby "ruby-grafana-reporter-#{GRAFANA_REPORTER_VERSION.join('.')}.rb -h"
end

task :testsingle do
  require_relative 'bin/get_single_file_application'

  # build single library file for validation
  File.write("spec/tmp_single_file_lib_ruby-grafana-reporter.rb", get_result('lib'))
  sh 'bundle exec rspec spec/test_single_file.rb'
end

task :buildexe do
  # read version information
  require_relative 'lib/VERSION'

  require 'openssl'
  GEMFILE_OPT = ""
  GEMFILE_OPT = "--gemfile Gemfile" if ENV['APPVEYOR']

  # find executable path of ruby to print builtin_dlls for debugging purposes
  BUILTIN_DLLS="#{RbConfig::CONFIG["bindir"].gsub(/\//, "\\")}\\ruby_builtin_dlls\\"
  puts "Showing content of #{BUILTIN_DLLS}: "
  # allow command to fail
  system "dir #{BUILTIN_DLLS}"

  POSTFIX=""
  POSTFIX="-x64" if BUILTIN_DLLS =~ /-x64\\/

  sh "ocran bin/ruby-grafana-reporter #{GEMFILE_OPT} --dll ruby_builtin_dlls/libssl-3#{POSTFIX}.dll --dll ruby_builtin_dlls/libcrypto-3#{POSTFIX}.dll --dll ruby_builtin_dlls/libgmp-10.dll --dll ruby_builtin_dlls/zlib1.dll --console --output ruby-grafana-reporter-#{GRAFANA_REPORTER_VERSION.join('.')}.exe #{OpenSSL::X509::DEFAULT_CERT_FILE}"
end

task :testexe do
  # read version information
  require_relative 'lib/VERSION'

  system "ruby-grafana-reporter-#{GRAFANA_REPORTER_VERSION.join('.')}.exe -h"
end

task :clean do
  rm Dir['*.gem'] << Dir['ruby-grafana-reporter-*.rb'] << Dir['ruby-grafana-reporter-*.exe'] << Dir["spec/tmp_single_file_lib_ruby-grafana-reporter.rb"]
end

task :test do
  sh 'bundle exec rspec spec/test_default.rb'
end
