require "json"
require "./run"

# TODO: Write documentation for `Hackacrow`
module Hackacrow
  VERSION = "0.1.0"

  def self.version
    VERSION
  end

  def self.display_help
    puts <<-HELP
    Usage: hackacrow [OPTIONS]
    Options:
      -h, --help        Display this help menu
      -c, --check       Check the output of a command
      -a, --argument    Instead of using stdin to test, use args
      -i, --input FILE  Specifies the JSON input file
      -o, --output FILE Specifies the JSON output file
    HELP
  end

  def self.main
    if ARGV.empty? || ARGV.includes?("-h") || ARGV.includes?("--help")
      puts "Hackacrow version #{VERSION}"
      display_help
    elsif ARGV.includes?("-c") || ARGV.includes?("--check")
      c_index = ARGV.index("-c") || ARGV.index("--check")
      a_index = ARGV.index("-a") || ARGV.index("--argument")

      if c_index && c_index < ARGV.size - 1
        exercise_index = ARGV[c_index + 1].to_i
        file_name = ARGV.last

        Run.run_test(exercise_index, file_name, a_index == nil)
      else
        puts "Argument missing. Usage: hackacrow -c EXERCISE_INDEX FILE_NAME"
      end
    else
      puts "Command not recognized. Use -h or --help to see available options."
    end
  end
end
