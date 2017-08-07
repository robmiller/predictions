require "pathname"

module Predictions
  class UserTables
    def initialize(data_dir = nil)
      @data_dir = data_dir || Pathname("data/")
    end

    def tables
      tables = files.map do |file|
        [file.basename(".txt").to_s, parse(file)]
      end

      Hash[tables]
    end

    private

    def files
      Pathname.glob(data_dir / "*.txt")
    end

    def parse(file)
      File.read(file).lines.each.with_index(1).map do |line, position|
        team, points = line.split("\t").map(&:strip)
        { position: position, team: team, points: points }
      end
    end

    attr_reader :data_dir
  end
end
