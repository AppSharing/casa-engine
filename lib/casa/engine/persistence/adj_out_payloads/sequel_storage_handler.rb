require 'casa/payload/transit_payload'

module CASA
  module Engine
    module Persistence
      module AdjOutPayloads
        class SequelStorageHandler < ::CASA::Engine::Persistence::AbstractPayloads::SequelStorageHandler

          def initialize options = nil

            super :adj_out_payloads, merged_options(options, {
              :schema_class => ::CASA::Payload::LocalPayload
            })

          end

        end
      end
    end
  end
end