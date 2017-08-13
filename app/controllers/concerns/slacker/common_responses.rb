module Slacker
  # All the very common message responses that are used in the App
  module CommonResponses
    # Primarily used when user asks for help
    def help_message
      help_text = "Hey, you! :wave:\n"
      help_text += "Would you like to indulge in some *Tic Tac Toe* fun?:\n"
      help_text += "Here are some commands:\n"
      help_text += "*/ttt new @sombody* will let you start a new game with anybody (not yourself, ofcourse - that would be wrong)\n"
      help_text += "*/ttt current* will let you know about the currently active game in that channel\n"
      help_text += "*/ttt leaderboard here* will display the leaders in that channel\n"
      help_text += "*/ttt leaderboard* will display the leaders across your team\n"
      return help_text
    end

    # Primarily used when slack token verification fails
    def verification_failed_message
      return "Verification Failed"
    end

    # Primarily used when user invokes an incomplete command
    def unidentified_command_message
      return "Hmmm. I can't figure out what that meant. Try */ttt help* for available commands."
    end

    # Primarily used when request makes no sense
    def incomplete_request_message
      return "Incomplete request"
    end

    # Primarily used when command isn't supported
    def unsupported_command_message
      return "That was not a supported command"
    end

    # Primarily used when the user interaction isn't supported
    def unsupported_action_message
      return "Sorry. I don't understand the request"
    end
  end
end
