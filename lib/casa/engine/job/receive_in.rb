require 'casa/engine/job/base'
require 'casa/attribute/loader_attribute_error'
require 'casa/attribute/loader_class_error'
require 'casa/attribute/loader_file_error'
require 'casa/receiver/strategy/client'
require 'casa/receiver/receive_in/body_parser_error'
require 'casa/receiver/receive_in/body_structure_error'
require 'casa/receiver/receive_in/request_error'
require 'casa/receiver/receive_in/response_error'

module CASA
  module Engine
    module Job
      class ReceiveIn < Base

        def start!

          super interval do

            adj_in_peers_handler.get_all.each do |peer|

            begin

              strategy = create_client_strategy peer, receiver_options
              strategy.execute!

              logger.info(peer[:uri]) { "Processed #{strategy.processed_payloads.length} payloads" }

            rescue CASA::Attribute::LoaderAttributeError,
                   CASA::Attribute::LoaderFileError,
                   CASA::Attribute::LoaderClassError,
                   CASA::Receiver::ReceiveIn::RequestError => e

              logger.fatal('Engine') { e.message }

            rescue CASA::Receiver::ReceiveIn::ResponseError,
                   CASA::Receiver::ReceiveIn::BodyStructureError,
                   CASA::Receiver::ReceiveIn::BodyParserError,
                   StandardError => e

              logger.error(peer[:uri]) { e.message }

            end

          end

          end

        end

        def receiver_options

          @receiver_options ||= {
            'persistence' => {
              'handler' => adj_in_payloads_handler
            },
            'logger' => logger
          }

        end

        def create_client_strategy peer, receiver_options

          strategy_options = receiver_options.clone
          strategy_options['secret'] = peer[:secret] if peer[:secret]
          CASA::Receiver::Strategy::Client.new peer[:uri], strategy_options

        end

      end
    end
  end
end