require "./spec_helper"

describe Run do
  describe "Load expect data" do
    temp_input = [{"2" => 4}, {"1000, 10, 1" => 1100}, {"['Test']" => "Ok!"}]

    temp_file_input = File.tempfile("100", ".json") do |file|
        file.print temp_input.to_json
    end

    Spec.after_suite {
      temp_file_input.delete
    }

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

    it "should use a custom expect file when pass flag -i" do
      ARGV.push("-i")
      ARGV.push(temp_file_input.path)
      result = Run.load_expect_data

      result.should eq temp_input

      ARGV.clear
    end

    it "should have correct input format when is multiple values" do
      ARGV.push("-i")
      ARGV.push(temp_file_input.path)

      result = Run.load_expect_data.as_a
      exercise = result[1].as_h

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
end
