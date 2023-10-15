module Docker
  def self.new(image : String)
    cmd_out = `bash scripts/docker.sh --up #{image} /tmp/#{image}`.strip
    exit_code = $?
    if !exit_code.success?
      puts "failed to initialize container for #{image}"
      puts cmd_out.split("\n").last

      exit 2
    end

    cmd_out
  end
end
