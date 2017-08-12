module Slacker
  module ResponsePackager

    # Package Messages with Statuses
    def success_response(message_hash)
      return {
        :json => message_hash,
        :status => :ok
      }
    end

    def not_found_response(message_hash)
      return {
        :json => message_hash,
        :status => :not_found
      }
    end

    def bad_request_response(message_hash)
      return {
        :json => message_hash,
        :status => :bad_request
      }
    end

    # Package Messages with Response types
    def build_ephemeral(message)
      if message.is_a? String
        return {:text => message, :response_type => "ephemeral"}
      elsif message.is_a? Hash
        return message.deep_merge!({:response_type => "ephemeral"})
      end
    end

    def build_in_channel(message)
      if message.is_a? String
        return {:text => message, :response_type => "in_channel"}
      elsif message.is_a? Hash
        return message.deep_merge!({:response_type => "in_channel"})
      end
    end

    def build_replace_original(message)
      if message.is_a? String
        return {:text => message, :replace_original => true}
      elsif message.is_a? Hash
        return message.deep_merge!({:replace_original => true})
      end
    end

    def build_not_replace_original(message)
      if message.is_a? String
        return {:text => message, :replace_original => false}
      elsif message.is_a? Hash
        return message.deep_merge!({:replace_original => false})
      end
    end
  end
end
