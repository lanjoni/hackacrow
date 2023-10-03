require "./spec_helper"

describe Run do
  describe "Load expect data" do
    it "should return error message when pass invalid argument" do
    end

    it "should have correct format for expect" do
      result = Run.load_expect_data.as_a
      first_expect = result[0]

      result.should be_a Array(JSON::Any)
      first_expect.size.should be >= 1
    end

    it "should use a custom input file" do
      temp_input = [{"2" => 4}]
      tempfile = File.tempfile("100", ".json") do |file|
        file.print temp_input.to_json
      end
      
      ARGV.push("-i")
      ARGV.push(tempfile.path)
      result = Run.load_expect_data

      result.should eq temp_input

      ARGV.clear
      tempfile.delete
    end

    it "should have correct input format when is multiple values" do
      temp_input = [{"1000, 10, 1": 1100}]
      tempfile = File.tempfile("1", ".json") do |file|
        file.print temp_input.to_json
      end
      
      ARGV.push("-i")
      ARGV.push(tempfile.path)
      result = Run.load_expect_data.as_a
      exercise = result[0].as_h

      exercise.each_key do |input|
        input.should contain ", "
      end

      ARGV.clear
      tempfile.delete
    end

    it "should have correct input format when is array" do
      temp_input = [{"['Test']": "Test curtiu isso"}]
      tempfile = File.tempfile("1", ".json") do |file|
        file.print temp_input.to_json
      end
      
      ARGV.push("-i")
      ARGV.push(tempfile.path)
      result = Run.load_expect_data.as_a
      exercise = result[0].as_h

      exercise.each_key do |input|
        input.should start_with "["
        input.should end_with "]"
      end

      ARGV.clear
      tempfile.delete
    end

    it "should have correct input format when is primitive" do
    end

    it "should have correct output format when is primitive" do
    end

    it "should have correct output format when is array" do
    end
  end


  describe "Run test" do
  end
end
