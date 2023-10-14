require "json"

module Run
  DEFAULT_LANG_JSON_PATH   = "./lang/lang.json"
  DEFAULT_EXPECT_JSON_PATH = "./expect/expect.json"

  def self.load_lang_data
    JSON.parse(File.read(DEFAULT_LANG_JSON_PATH))
  end

  def self.load_expect_data(stdout : IO = STDOUT)
    expect_json_file = File.read(DEFAULT_EXPECT_JSON_PATH)

    if ARGV.includes?("-i") || ARGV.includes?("--input")
      i_index = ARGV.index("-i") || ARGV.index("--input")
      if i_index && i_index < ARGV.size - 1
        expect_json_file = File.read(ARGV[i_index + 1])
      else
        stdout.puts "Argument missing. Usage: hackacrow -i INPUT_FILE"
      end
    end

    JSON.parse(expect_json_file)
  end

 def self.get_command(initial_command : JSON::Any, file_name : String) : String
    initial_command = initial_command.to_s

    return initial_command.sub("$", file_name) if initial_command.includes?("$")
    return "#{initial_command} #{file_name}"
  end

  def self.run_test(exercise_index : Int, file_name : String, run_with_stdin = true, run_with_verbose = false, stdout : IO = STDOUT)
    lang_data = load_lang_data
    expect_data = load_expect_data

    if exercise_index >= 0 && exercise_index < expect_data.size
      exercise = expect_data[exercise_index]
      file_extension = File.extname(file_name).sub(".", "")

      if lang_data.as_h.has_key?(file_extension)
        command = get_command(lang_data[file_extension], file_name)

        exercise.as_h.each do |key, value|
          if run_with_stdin
            command_output = `echo #{key} | #{command}`.strip
          else
            command_output = `#{command} #{key}`.strip
          end
          output_lines = command_output.split("\n")
          last_line = output_lines.last
          if last_line == value
            stdout.puts "✅ Successful test for #{file_name} (Exercise #{exercise_index} - Input #{key} - Expected #{value} - Got #{last_line})"
          else
            stdout.puts "❌ Test failed for #{file_name} (Exercise #{exercise_index} - Input #{key} - Expected #{value} - Got #{last_line})"
          end
          if run_with_verbose && !run_with_stdin
            puts "\"#{command} #{key}\""
          else 
            if run_with_verbose && run_with_stdin
              puts "\"echo #{key} | #{command}\""
            end
          end
        end
      else
        stdout.puts "Unsupported file extension: #{file_extension}"
      end
    else
      stdout.puts "Exercise not found: #{exercise_index}"
    end
  end
end
