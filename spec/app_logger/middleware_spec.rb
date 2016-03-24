require "spec_helper"

describe AppLogger::Middleware do
  include Rack::Test::Methods

  let(:log_level) { Logger::INFO }
  let(:test_opts) { { logger: logger, log_level: log_level } }
  let(:test_app) { TestApplication.new }
  let(:app) { AppLogger::Middleware.new(test_app, test_opts) }

  def assert_response(response, &block)
    expect(response.status).to eq 200
    expect(response.body).to eq "success"
    expect(response.header["Content-Type"]).to eq "text/html;charset=utf-8"
    block.call(response) if block_given?
  end

  def assert_common_log_message(m)
    expect(m[:host]).to eq "127.0.0.1"
    expect(m[:user]).to eq "test@example.com"
    expect{ Time.parse(m[:time]) }.to_not raise_error
    expect(m[:method]).to eq "GET"
    expect(m[:http_version]).to eq "HTTP/1.1"
    expect(m[:status_code]).to eq "200"
    expect(m[:length].to_i).to eq "success".length
    expect(m[:response_time]).to be_truthy
  end

  LOG_PATTERN = /^(?<host>\S+) - (?<user>\S+) \[(?<time>\S+)\] "(?<method>\S+) (?<path_and_query>\S+) (?<http_version>\S+)" (?<status_code>\d+) (?<length>\S+) (?<response_time>\S+)\n/

  describe "Not Logger" do
    let(:logger) { @logger ||= StringIO.new }

    it 'should say formatterd string' do
      current_session.header('Version', 'HTTP/1.1')

      expect(logger).to receive(:write) do |msg|
        m = LOG_PATTERN.match(msg)

        assert_common_log_message(m)
        expect(m[:path_and_query]).to eq "/"
      end

      get '/'
      assert_response(last_response)
    end
  end

  describe "Logger" do
    let(:logger) { @logger ||= Logger.new($stdout) }

    [ Logger::INFO, Logger::DEBUG ].each do |level|

      context "log level is #{level}" do
        let(:log_level) { level }
        it 'should say hash' do
          current_session.header('Version', 'HTTP/1.1')

          expect(logger).to receive(:log) do |level, msg|
            expect(level).to eq level

            assert_common_log_message(msg)
            expect(msg[:path]).to eq "/"
            expect(msg[:query]).to eq ""
            expect(msg[:request_line]).to eq "GET / HTTP/1.1"
          end

          get '/'
          assert_response(last_response)
        end
      end
    end
  end
end
