require "logger"
require "rack"

module AppLogger
  class Middleware < Rack::CommonLogger
    attr_reader :log_level

    def initialize(app, options)
      super(app, options[:logger])
      @log_level = options[:log_level] || Logger::INFO
    end

    private
    FORMAT = %{%s - %s [%s] "%s %s%s %s" %d %s %s\n}

    def log(env, status, header, began_at)
      msg = message(env, status, header, began_at)

      logger = @logger || env['rack.errors']
      if logger.respond_to?(:log)
        msg[:request_line] = "#{msg[:method]} #{msg[:path]}#{msg[:query]} #{msg[:http_version]}"
        logger.log(log_level, msg)
      elsif logger.respond_to?(:write)
        logger.write(format_message(msg))
      else
        logger << format_message(msg)
      end
    end

    def message(env, status, header, began_at)
      method       = env[Rack::REQUEST_METHOD]
      path         = env[Rack::PATH_INFO]
      query        = env[Rack::QUERY_STRING].empty? ? "" : "?"+env[Rack::QUERY_STRING]
      http_version = env["HTTP_VERSION"] || "-"

      now = Time.now
      {
        remote:        env['HTTP_X_FORWARDED_FOR'] || env["REMOTE_ADDR"] || "-",
        user:          env["REMOTE_USER"] || "-",
        method:        method,
        path:          path,
        query:         query,
        http_version:  http_version,
        status:        status.to_s[0..3].to_i,
        response_length: extract_content_length(header).to_i,
        response_time: (now - began_at)
      }
    end

    def format_message(msg)
      FORMAT % [
        msg[:host],
        msg[:user],
        msg[:time],
        msg[:method],
        msg[:path],
        msg[:query],
        msg[:http_version],
        msg[:status],
        msg[:response_length],
        msg[:response_time]
      ]
    end
  end
end
