module RubyOS::Memory
  class FirstFitManager < Manager
    def assign_process_base_address(process)
      super
      # Find the first available address
      hole = find_hole
      raise OutOfMemoryError.new if hole.nil?

      if hole[:mem_available] >= process.memory_required
        process.base_address = hole[:base_address]
        process.memory_limit = process.memory_required
      else
        loop do
          # The space between starting_address and first_reserved is not enough
          # for the requesting process. So continue on to the next 'hole'
          hole = find_hole(hole[:end_address])

          # if the address is nil, then there were no further 'holes'
          raise NoContiguousMemoryError.new if hole.nil?

          if hole[:mem_available] >= process.memory_required
            process.base_address = hole[:base_address]
            process.memory_limit = process.memory_required
            break
          end
        end
      end

      reserve_memory(process.base_address, process.memory_limit)
    end
  end
end
