module RubyOS::Memory
  class Error <  RuntimeError
  end

  # When a process cannot be allocated in memory because none is available.
  # NOTE NoMemoryError might be more succient, but as there's actually a Ruby
  # defined error called NoMemoryError... it seemed like a good idea not to
  # shadow it with our own (just in case).
  class OutOfMemoryError < Error
  end

  # When a process requires contiguous memory assignment, and there is enough
  # memory but not enough of it is contiguous. (External Fragementation)
  class NoContiguousMemoryError < OutOfMemoryError
  end

  # When an assignment is requested past available memory limits
  class OutOfBoundsAssignment < Error
  end
end
