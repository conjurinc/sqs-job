class UnrecoverableException < RuntimeError
end

class InvalidMessageException < UnrecoverableException
  def initialize(message)
    super message.errors.full_messages.join(', ')
  end
end

class MissingTypeException < UnrecoverableException
end

class SignatureInvalidException < UnrecoverableException
end

class UnrecognizedMessageTypeException < UnrecoverableException
end
