require "./spec_helper"

describe Hackacrow do
  {% for flag in ["-h", "--help"] %}
    it "should display help message when use {{ flag.id }}", tags: "fast" do
      stdout = IO::Memory.new(0)
      ARGV.push({{ flag }})
      Hackacrow.main(stdout)

      stdout.to_s.should match(/Hackacrow version/)
      ARGV.clear
    end
  {% end %}

  {% for flag in ["-c", "--check"] %}
    it "should get a error message when not pass argument with {{ flag.id }}", tags: "fast" do
      stdout = IO::Memory.new(0)
      ARGV.push({{ flag }})

      Hackacrow.main(stdout)

      stdout.to_s.should match(/Argument missing/)
      ARGV.clear
    end
  {% end %}

  it "should get a error message when not recognized a flag", tags: "fast" do
      stdout = IO::Memory.new(0)
      ARGV.push("-test")

      Hackacrow.main(stdout)

      stdout.to_s.should match(/Command not recognized/)
  end
end
