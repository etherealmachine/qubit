module Qubit
  class PruneEventsJob < ApplicationJob
    queue_as :default

    BATCH_SIZE = 1000

    def perform
      events_to_process = Event.includes(:variant)
        .where(variant: { id: nil })
        .limit(BATCH_SIZE)

      return if events_to_process.empty?

      events_to_process.destroy_all

      # Schedule another job if there are likely more records to process
      if events_to_process.count == BATCH_SIZE
        PruneEventsJob.perform_later
      end
    end
  end
end
