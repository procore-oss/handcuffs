module Handcuffs::Logger

  def migrate(direction)
    start_time = Time.now
    super
    end_time = Time.now
    phase = @handcuffs_phase || Handcuffs.config.default_phase
    log(version, phase, direction, start_time, end_time)
  end

  private

  def log(version, phase, direction, start_time, end_time)
    if(filename)
      File.open(filename, 'a') do |file|
        file.puts({
          version: version,
          phase: phase,
          direction: direction,
          start_time: start_time,
          end_time: end_time
        }.to_json)
      end
    end
  end

  def filename
    ENV['HANDCUFFS_LOG']
  end

end
