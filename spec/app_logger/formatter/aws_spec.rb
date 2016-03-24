require 'spec_helper'

describe AppLogger::Formatter::Aws do
  let(:hostname) { `hostname`.chomp }
  let(:pid)      { $$ }
  let(:severity) { "DEBUG" }
  let(:datetime) { Time.now }
  let(:progname) { File.basename(__FILE__) }
  let(:message)  { "this is test" }

  let (:formatter)   { AppLogger::Formatter::Aws.new }
  let (:pattern_map) {
    {
      client_class:              "Aws::S3::Client",
      http_response_status_code: "200",
      time:                      "0.1",
      retries:                   "1",
      operation:                 "put_object",
      request_params:            { bucket: :mybucket, key: :mykey }.to_json,
      error_class:               "Error",
      error_message:             "error occurred",
    }
  }

  def assert_json(msg, &block)
    expect(msg).to match /.+\n\z/
    expect { JSON.parse(msg) }.to_not raise_error
    block.call JSON.parse(msg, symbolize_names: true) if block_given?
  end

  it "can be used logger" do
    logger = Logger.new($stdout)
    logger.formatter = formatter

    expect($stdout).to receive(:write) {|msg| assert_json(msg); msg }
    logger.info(message)
  end

  it "should return formatted message include common message" do
    msg = formatter.call(severity, datetime, progname, message)
    assert_json(msg) do |parsed|
      expect(parsed[:_host]).to     eq hostname
      expect(parsed[:_pid]).to      eq pid
      expect(parsed[:_severity]).to eq severity
      expect(parsed[:_time]).to     eq datetime.iso8601
      expect(parsed[:_progname]).to eq progname
    end
  end

  it "should return formatted message include aws formatter pattern values" do
    pattern = AppLogger::Formatter::Aws.pattern
    message = pattern.gsub(/:(\w+)/) {|sym| pattern_map[sym[1..-1].to_sym] }

    msg = formatter.call(severity, datetime, progname, message)
    assert_json(msg) do |parsed|
      expect(parsed[:client_class]).to  eq pattern_map[:client_class]
      expect(parsed[:status_code]).to   eq pattern_map[:http_response_status_code]
      expect(parsed[:response_time]).to eq pattern_map[:time]
      expect(parsed[:retries]).to       eq pattern_map[:retries]
      expect(parsed[:operation]).to     eq "#{pattern_map[:operation]}(#{pattern_map[:request_params]})"
      expect(parsed[:error_class]).to   eq pattern_map[:error_class]
      expect(parsed[:error_message]).to eq pattern_map[:error_message]
    end
  end
end
