require 'spec_helper'

describe AppLogger::Formatter::Json do
  let(:hostname) { `hostname`.chomp }
  let(:pid)      { $$ }
  let(:severity) { "DEBUG" }
  let(:datetime) { Time.now }
  let(:progname) { File.basename(__FILE__) }
  let(:message)  { "this is test" }

  let (:formatter) { AppLogger::Formatter::Json.new }

  def assert_json(msg, &block)
    expect(msg).to match /.+\n\z/
    expect { JSON.parse(msg) }.to_not raise_error
    block.call JSON.parse(msg, symbolize_names: true) if block_given?
  end

  it "can be used logger" do
    logger = Logger.new($stdout)
    logger.formatter = formatter

    expect($stdout).to receive(:write) {|msg| assert_json(msg) }
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

  it "should return formatted message include string value with log" do
    msg = formatter.call(severity, datetime, progname, message)
    assert_json(msg) do |parsed|
      expect(parsed[:log]).to eq message
    end
  end

  it "should return formatted message include merged hash" do
    hash = { foo: :bar, msg: message }
    msg = formatter.call(severity, datetime, progname, hash)
    assert_json(msg) do |parsed|
      expect(parsed[:foo]).to eq "bar"
      expect(parsed[:msg]).to eq message
      expect(parsed[:log]).to be_nil
    end
  end
end
