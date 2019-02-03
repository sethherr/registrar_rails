# frozen_string_literal: true

# Using activejob is fucking slow. Just use sidekiq
# ActiveJob is included to make actionmailer work with delayed, and maybe other things
# ... But all the jobs are sidekiq only
class ApplicationJob
  include Sidekiq::Worker
end
