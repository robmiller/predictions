module Predictions
  class DiffTable
    def initialize(actual_table)
      @actual_table = actual_table
    end

    def diff(other_table)
      other_table.map do |guessed|
        real = actual_table.find { |p| p[:team] == guessed[:team] }
        guessed[:difference] = (real[:position] - guessed[:position]).abs
        guessed[:points_difference] = (real[:points] - guessed[:points]).abs
        guessed
      end
    end

    def score(other_table)
      diff(other_table).reduce(0) { |score, p| score + p[:difference] }
    end

    private

    attr_reader :actual_table
  end
end
