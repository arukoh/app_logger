require "app_logger/version"
require "app_logger/middleware"
require "app_logger/formatter"
require "active_support"

module AppLogger
  class << self
    def new_logger(logdev, level: nil, formatter: nil, console: false)
      logger = ActiveSupport::Logger.new(logdev)
      logger.level = level if level
      logger.formatter = formatter if formatter
      logger.extend ActiveSupport::Logger.broadcast(console_logger) if console
      logger
    end

    def new_force_formatted_logger(logdev, level: nil, formatter: nil, console: false, severity: Logger::UNKNOWN)
      logger = new_logger(logdev, level: level, formatter: formatter, console: console)
      logger.instance_variable_set(:@_severity, severity)
      logger.instance_eval do |obj|
        class << self
          define_method :<< do |msg|
            return true if @logdev.nil? or @_severity < @level
            @logdev.write(format_message(format_severity(@_severity), Time.now, @progname, msg))
            true
          end
        end
      end
      logger
    end

    def console_logger
      @@console_logger ||= ActiveSupport::Logger.new(STDOUT)
    end
  end
end
