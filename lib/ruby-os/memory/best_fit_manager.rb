module RubyOS::Memory
  class BestFitManager < Manager
    def assign_process_base_address(process)
      super
      final_hole = {}
      # Find the first available hole
      hole = find_hole
      raise OutOfMemoryError.new if hole.nil?

      # There is at least one other reserved spot, so we need store the current
      # whole information if the hole is large enough:
      if hole[:mem_available] >= process.memory_required
        final_hole = hole
      end

      loop do
        # Find the next 'hole'
        hole = find_hole(hole[:end_address])

        # There are no further holes
        break if hole.nil?

        if hole[:mem_available] >= process.memory_required
          # Only update the target hole if it's a better fit than the current
          # one.
          if final_hole.empty? || final_hole[:mem_available].send(self.comparitor, hole[:mem_available])
            final_hole = hole
          end
        end
      end

      # If we never set the 'hole' then there was no 'hole' big enough for the
      # requested process
      raise NoContiguousMemoryError.new if final_hole.empty?

      # Set memory info on process & reserve memory
      # NOTE The current memory limit is fixed to the required memory of the
      # process for now...
      final_hole[:memory_limit] = process.memory_required
      process.base_address = final_hole[:base_address]
      process.memory_limit = final_hole[:memory_limit]
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
