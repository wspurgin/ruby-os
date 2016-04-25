module RubyOS::Memory
  class Error <  RuntimeError
  end

  # When a process cannot be allocated in memory because none is available.
  # NOTE NoMemoryError might be more succient, but as there's actually a Ruby
  # defined error called NoMemoryError... it seemed like a good idea not to
  # shadow it with our own (just in case).
  class OutOfMemoryError < Error
  end

  # When a process requires contiguous memory assignment, and there is free
  # memory but there is not enough contiguous memory to service the request.
  # (and when there's enough available memory to service the request this is
  # actually External Fragementation).
  class NoContiguousMemoryError < Error
  end

  # When an assignment is requested past available memory limits
  class OutOfBoundsAssignment < Error
  end

  # When an assignment is requested over an existing assignment
  class AssignmentError < Error
  end
end
