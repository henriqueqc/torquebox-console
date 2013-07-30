# Copyright 2012 Lance Ball
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'stomp'
require 'readline'

module TorqueBox
  module Console
    class Client
      DEFAULT_HEADERS = { "accept-version" => "1.1" }
      DEFAULT_HOST = { :host => "localhost", :port => 8675 }
      DEFAULT_PARAMS  = { :max_reconnect_attempts => -1, :reliable => false }

      attr_accessor :client

      def initialize (host = DEFAULT_HOST)
        build_globals(host)
        @client = Stomp::Client.new(@params)
      rescue Stomp::Error::MaxReconnectAttempts
        puts "Cannot connect to TorqueBox. Are you sure the server is running?"
      end

      def self.connect (host = DEFAULT_HOST)
        Client.new(host).run
      end

      def run
        if client
          trap("INT") {
            client.close if client.open?
            puts "Disconnecting console, press enter to exit"
          }
          prompt = "TorqueBox> "
          received_prompt = false
          client.subscribe("/stomplet/console") do |msg|
            if msg.headers['prompt']
              prompt = msg.body
              received_prompt = true
            else
              puts msg.body
            end
          end
          # Since our messaging is async, sleep
          # before displaying the prompt
          while !received_prompt && client.open?
            sleep 0.05
          end
          while client.open? && (input = Readline.readline(prompt, true))
            received_prompt = false
            if input == 'exit' || input == 'quit'
              client.unsubscribe('/stomplet/console')
              client.close
            end
            client.publish("/stomplet/console", input) if client.open?
            while !received_prompt && client.open?
              sleep 0.05 # again with the async
            end
          end
          if client.open?
            client.unsubscribe('/stomplet/console')
          end
          $stderr.puts "Connection closed."
          # Hide any errors printed after we've unsubscribed
          $stderr.close
        end
      end
      
      protected
      
      def build_globals (host)
        @hosts = [host]
        @headers = DEFAULT_HEADERS.merge({ :host => host[:host] })
        @params = DEFAULT_PARAMS.merge({ :hosts => @hosts, :connect_headers => @headers })
      end
    end
  end
end
