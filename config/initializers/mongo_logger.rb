$cycleLog = false
module Mongo
  module Logging

    def log_operation(name, payload)
      @logger ||= nil
      return unless @logger

      $cycleLog = !$cycleLog

      msg = "#{payload[:database]}['#{payload[:collection]}'].#{name}("
      msg += payload.values_at(:selector, :document, :documents, :fields ).compact.map(&:inspect).join(', ') + ")"
      msg += ".skip(#{payload[:skip]})"  if payload[:skip]
      msg += ".limit(#{payload[:limit]})"  if payload[:limit]
      msg += ".sort(#{payload[:order]})"  if payload[:order]
      if $cycleLog
        @logger.debug "MONGO ".green.bold + msg
      else
        @logger.debug "MONGO ".yellow.bold + msg.bold
      end
    end

  end
end