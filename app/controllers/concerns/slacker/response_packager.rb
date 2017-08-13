module Slacker
  module ResponsePackager

    # Package Messages with Statuses

    # Response is a success (200)
    def success_response(message_hash)
      return {
        :json => message_hash,
        :status => :ok
      }
    end

    # Response is a not_found error (404)
    def not_found_response(message_hash)
      return {
        :json => message_hash,
        :status => :not_found
      }
    end

    # Response is a bad_request error (400)
    def bad_request_response(message_hash)
      return {
        :json => message_hash,
        :status => :bad_request
      }
    end

    # Package Messages for responses to Slack commands

    # Print ephemeral message
    # Message appears to the invoker only
    # replaces the original message
    def build_ephemeral(message)
      if message.is_a? String
        return {:text => message, :response_type => "ephemeral"}
      elsif message.is_a? Hash
        return message.deep_merge!({:response_type => "ephemeral"})
      end
    end

    # Print in_channel message
    # Message appears to everybody in that channel
    # doesn't replace the original message
    def build_in_channel(message)
      if message.is_a? String
        return {:text => message, :response_type => "in_channel"}
      elsif message.is_a? Hash
        return message.deep_merge!({:response_type => "in_channel"})
      end
    end

    # Package Messages for responses to Slack interactions

    # Replace Original message
    # The interaction updates the original message with the response
    def build_replace_original(message)
      if message.is_a? String
        return {:text => message, :replace_original => true}
      elsif message.is_a? Hash
        return message.deep_merge!({:replace_original => true})
      end
    end

    # Doesn't replace Original message
    # The interaction adds the response to the channel
    def build_not_replace_original(message)
      if message.is_a? String
        return {:text => message, :replace_original => false}
      elsif message.is_a? Hash
        return message.deep_merge!({:replace_original => false})
      end
    end
  end
end
