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

    it "should have correct input format for expect" do
    end

    it "should have correct output format for expect" do
    end
  end
end
