module AppLogger
  module Formatter
    class Aws < Json
      class << self
        def pattern
          pattern = []
          pattern << ":client_class"
          pattern << ":http_response_status_code"
          pattern << ":time"
          pattern << ":retries"
          pattern << ":operation(:request_params)"
          pattern << ":error_class"
          pattern << ":error_message"
          pattern.join(' ') + "\n"
        end
      end

      private
      def msg2hash(message)
        msg = message.to_s.strip
        client, code, time, retries, ope, e_class, e_msg = msg.split(/ /, 7)
        {
          _formatter:    :aws,
          client_class:  client,
          status_code:   code,
          response_time: time, # sec
          retries:       retries,
          operation:     ope,
          error_class:   e_class,
          error_message: e_msg
        }
      end
    end
  end
end
