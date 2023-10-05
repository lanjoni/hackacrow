require "./spec_helper"

describe Run do
  temp_input = [{"1000, 10, 1" => "1100"}, {"2" => "8", "3" => "28"}, {"['Test']" => "Ok!"}]

  temp_file_input = File.tempfile("expect", ".json") do |file|
    file.print temp_input.to_json
  end

  Spec.after_suite {
    temp_file_input.delete
  }

  describe "Load lang data", tags: "fast" do
    result = Run.load_lang_data

    result.should be_a JSON::Any
  end

  describe "Load expect data", tags: "fast" do
    it "should have correct format for expect" do
      result = Run.load_expect_data.as_a
      first_expect = result[0]

      result.should be_a Array(JSON::Any)
      first_expect.size.should be >= 1
    end

    it "should use a default expect file when not pass flag -i" do
      result = Run.load_expect_data
      default_expect_file = File.read "./expect/expect.json"

      result.should eq JSON.parse(default_expect_file)
    end

    {% for flag in ["-i", "--input"] %}
      it "should use a custom expect file when pass flag {{ flag.id }}" do
        ARGV.push({{ flag }})
        ARGV.push(temp_file_input.path)
        result = Run.load_expect_data

        result.should eq temp_input

        ARGV.clear
      end
    {% end %}
    
    it "should have correct input format when is multiple values" do
      ARGV.push("-i")
      ARGV.push(temp_file_input.path)

      result = Run.load_expect_data.as_a
      exercise = result[0].as_h

      exercise.each_key do |input|
        input.should contain ", "
      end

      ARGV.clear
    end

    it "should have correct input format when is array" do
      ARGV.push("-i")
      ARGV.push(temp_file_input.path)

      result = Run.load_expect_data.as_a
      exercise = result[2].as_h

      exercise.each_key do |input|
        input.should start_with "["
        input.should end_with "]"
      end

      ARGV.clear
    end
  end


  describe "Run test", tags: "slow" do
    it "should get a error message when not support file extension" do
      stdout = IO::Memory.new
      result = Run.run_test(0, "0.error_language", stdout)

      stdout.to_s.should match(/Unsupported file extension/)
    end

    it "should get a error message when not found exercise" do
      stdout = IO::Memory.new
      result = Run.run_test(9999, "9999.cr", stdout)

      stdout.to_s.should match(/Exercise not found: \d+/)
    end


    it "should get correct feedback for success/failed test case" do
      ARGV.push("-i")
      ARGV.push(temp_file_input.path)

      stdout = IO::Memory.new
      result = Run.run_test(1, "samples/1.cr", stdout)

      stdout.to_s.should match(/Successful test for .+ \(/)
      stdout.to_s.should match(/Test failed for .+ \(/)

      ARGV.clear
    end
  end
end
