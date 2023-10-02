require "json"

module Run
  DEFAULT_LANG_JSON_PATH = "./lang/lang.json"
  DEFAULT_EXPECT_JSON_PATH = "./expect/expect.json"

  def self.load_lang_data
    JSON.parse(File.read(DEFAULT_LANG_JSON_PATH))
  end

  def self.load_expect_data
    expect_json_file = File.read(DEFAULT_EXPECT_JSON_PATH)

    if ARGV.includes?("-e") || ARGV.includes?("--expect")
      e_index = ARGV.index("-e") || ARGV.index("--expect")
      if e_index && e_index < ARGV.size - 1
        expect_json_file = File.read(ARGV[e_index + 1])
      else
        puts "Argument missing. Usage: hackacrow -e EXPECT_FILE"
      end
    end

    JSON.parse(expect_json_file)
  end

  def self.run_test(exercise_index : Int, file_name : String)
    lang_data = load_lang_data
    expect_data = load_expect_data

    if exercise_index >= 0 && exercise_index < expect_data.size
      exercise = expect_data[exercise_index]
      file_extension = File.extname(file_name).sub(".", "")
      
      if lang_data.as_h.has_key?(file_extension)
        command = "#{lang_data[file_extension]} #{file_name}"

        exercise.as_h.each do |key, value|
          command_output = `echo #{key} | #{command}`.strip
          output_lines = command_output.split("\n")
          last_line = output_lines.last
          if last_line == value
            puts "✅ Successful test for #{file_name} (Exercise #{exercise_index} - Input #{key} - Expected #{value} - Got #{last_line})"
          else
            puts "❌ Test failed for #{file_name} (Exercise #{exercise_index} - Input #{key} - Expected #{value} - Got #{last_line})"
          end
        end
      else
        puts "Unsupported file extension: #{file_extension}"
      end
    else
      puts "Exercise not found: #{exercise_index}"
    end
  end
end
