require "json"

module AppLogger
  module Formatter
    class Json
      FORMAT = "%s\n"

      def initialize(hostname=`hostname`.chomp)
        @hostname = hostname
      end

      def call(severity, datetime, progname, message)
        msg = msg2hash(message)
        FORMAT % common_msg(severity, datetime, progname).merge(msg).to_json
      end

      private
      def msg2hash(message)
        case message
        when Hash
          message
        else
          { log: message.to_s }
        end
      end

      def common_msg(severity, datetime, progname)
        {
          _host:     @hostname,
          _pid:      $$,
          _severity: severity,
          _time:     datetime.iso8601,
          _progname: progname
        }
      end
    end
  end
end
