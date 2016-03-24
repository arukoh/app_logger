require 'spec_helper'

describe AppLogger do
  it 'has a version number' do
    expect(AppLogger::VERSION).not_to be nil
  end

  let(:logdev)  { StringIO.new }
  let(:pattern) { "%s\n" }
  let(:message) { "this is test" }

  it "instanciate new logger" do
    logger = AppLogger.new_logger(logdev, level: Logger::INFO)
    expect(logdev).to receive(:write).with(pattern % message).once
    expect(STDOUT).to receive(:write).never

    logger.info message
    logger.debug message
  end

  it "instanciate new logger with console" do
    logger = AppLogger.new_logger(logdev, level: Logger::INFO, console: true)
    expect(logdev).to receive(:write).with(pattern % message).once
    expect(STDOUT).to receive(:write).with(pattern % message).twice

    logger.info message
    logger.debug message
  end

  it "instanciate new force formatted logger" do
    formatter = lambda do |severity, datetime, progname, message|
      "%s\t%s\n" % [ severity, message ]
    end
    logger = AppLogger.new_force_formatted_logger(logdev, level: Logger::INFO, formatter: formatter)
    expect(logdev).to receive(:write).with("INFO\t#{message}\n").once
    expect(STDOUT).to receive(:write).never

    logger.info message
    logger.debug message
  end
end
