require 'rake'

class Handcuffs::LogMigrator

  def initialize(filename, direction)
    @filename = filename
    @direction = direction
  end

  def migrate
    contents = read_file.reverse
    hashes = contents.map { |line| JSON.parse(line).symbolize_keys }
    versions = hashes.map { |hash| hash[:version] }
    versions.each { |version| run(version) }
  end

  def run(version)
    ENV['VERSION'] = version.to_s
    Rake::Task["db:migrate:#{@direction}"].reenable
    Rake::Task["db:migrate:#{@direction}"].invoke
  end

  private

  def read_file
    File.readlines(@filename)
  end
end
