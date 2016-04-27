module RubyOS::Memory
  class WorstFitManager < BestFitManager
    # The only difference between the logic of the Best Fit algorithm and Worst
    # Fit algorithm is what comparison is used when comparing the size of holes
    # in memory.
    def comparitor
      :<
    end
  end
end
