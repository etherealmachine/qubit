module Qubit
  class RunCensusJob < ApplicationJob
    queue_as :default

    def perform(census)
      census.update!(status: 'running')

      subject_class = census.subject_type.constantize
      subjects = subject_class
        .order('RANDOM()')
        .limit(census.sample_size)

      condition = Qubit::Condition.parse(subject_class, census.condition)

      subjects.each do |subject|
        census.sample(subject)
      end

      census.update!(status: 'completed')
    rescue StandardError => e
      census.update!(status: 'failed')
      raise e
    end
  end
end 