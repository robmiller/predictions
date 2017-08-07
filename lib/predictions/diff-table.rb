module Predictions
  class DiffTable
    def initialize(actual_table)
      @actual_table = actual_table
    end

    def diff(other_table)
      other_table.map do |guessed|
        real = actual_table.find { |p| p[:team] == guessed[:team] }
        guessed[:difference] = (real[:position] - guessed[:position]).abs
        guessed
      end
    end

    private

    attr_reader :actual_table
  end
end
