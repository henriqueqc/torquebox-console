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
      HEADERS = { "accept-version" => "1.1", "host" => "localhost" }
      HOSTS   = [{:host => "localhost", :port => 8675}]
      PARAMS  = { :connect_headers => HEADERS, :hosts => HOSTS, :max_reconnect_attempts => -1 }

      attr_accessor :client, :closed

      def initialize
        @closed = false
        @client = Stomp::Client.new( PARAMS )
      rescue Stomp::Error::MaxReconnectAttempts
        puts "Cannot connect to TorqueBox. Are you sure the server is running?"
      end

      def self.connect
        Client.new.run
      end

      def run
        if client
          trap("INT") {
            @closed = true
            puts ""
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
          while !received_prompt && !closed
            sleep 0.05
          end
          while !closed && (input = Readline.readline( prompt, true ))
            received_prompt = false
            client.publish("/stomplet/console", input) unless closed
            while !received_prompt && !closed
              sleep 0.05 # again with the async
            end
          end
          client.unsubscribe('/stomplet/console')
          # Hide any errors printed after we've unsubscribed
          $stderr.close
        end
      end
    end
  end
end
