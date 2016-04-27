module RubyOS::Memory
  class BestFitManager < Manager
    def assign_process_base_address(process)
      super
      hole = {}
      starting_address, _ = memory_map.find(proc { [nil, nil] }) { |addr, flag| flag == FREE }
      raise OutOfMemoryError.new if starting_address.nil?

      # Find the first reserved location
      first_reserved, _ = memory_map
        .find(proc { [nil, nil] }) { |addr, flag| addr > starting_address and flag == RESERVED }

      # if the first_reserved address is nil, then there is only one available
      # space after the starting address, so the 'first_reserved' address is
      # the highest_address + 1 (which doesn't technically exist, but we can't
      # go past the total available space so it's basically reserved...).
      first_reserved = highest_address + 1 if first_reserved.nil?

      # There is at least one other reserved spot, so we need store the current
      # whole information if the hole is large enough:
      if first_reserved - starting_address >= process.memory_required
        hole[:base_address] = starting_address
        hole[:memory_limit] = process.memory_required
        hole[:mem_available] = first_reserved - starting_address
      end

      loop do
        # Find the next 'hole'
        starting_address, _ = memory_map
          .find(proc { [nil, nil] }) { |addr, flag| addr > first_reserved and flag == FREE }

        # There are no further holes
        break if starting_address.nil?

        # Find the end of the hole:
        first_reserved, _ = memory_map
          .find(proc { [nil, nil] }) { |addr, flag| addr > starting_address and flag == RESERVED }

        # If it's nil, the highest_address is the last free spot
        first_reserved = highest_address + 1 if first_reserved.nil?

        hole_size = first_reserved - starting_address
        if hole_size >= process.memory_required
          # Only update the target hole if it's a better fit than the current
          # one.
          if hole.empty? || hole[:mem_available].send(self.comparitor, hole_size)
            hole[:base_address] = starting_address
            hole[:mem_available] = hole_size
          end
        end
      end

      # If we never set the 'hole' then there was no 'hole' big enough for the
      # requested process
      raise NoContiguousMemoryError.new if hole.empty?

      # Set memory info on process & reserve memory
      process.base_address = hole[:base_address]
      process.memory_limit = hole[:memory_limit]
      reserve_memory(process.base_address, process.memory_limit)
    end

    # Best fit wants to find the smaller hole size
    # This is only here so that the algorithm above can be reused for Worst Fit
    # (since they have exactly the same steps, only Worst fit want the *largest*
    # hole, not the smallest).
    def comparitor
      :>
    end
  end
end
