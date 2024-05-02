# frozen_string_literal: true

module MiscDataTools
  class Jp2ToJpg
    class << self
      def call(...) = new(...).call
    end

    # @param source [String] path to source directory
    # @param target [String] path to target directory
    def initialize(source:, target:)
      @source = validate_source(source)
      @target = set_target(target)
      @allfiles = Dir.new(@source).children
      FileUtils.mkdir_p(@target) unless Dir.exist?(@target)
      @logger = Logger.new(File.join(@target, "log.txt"))
    end

    def call
      convert_files
      copy_non_jp2s
    end

    private

    attr_reader :source, :target, :allfiles, :logger

    def validate_source(source)
      result = File.expand_path(source)
      return result if Dir.exist?(result)

      puts "Source directory does not exist at #{source}"
      exit 0
    end

    def set_target(target)
      return File.expand_path(target) if target

      File.join(File.dirname(source), "#{File.basename(source)}_conv")
    end


    def convert_files
      to_convert = jp2s

      progressbar = ProgressBar.create(
        title: "Converting files",
        starting_at: 0,
        total: to_convert.length,
        format: "%a %E %B %c %C %p%% %t"
      )
      to_convert.each do |file|
        convert_file(file)
        progressbar.increment
      end
    end

    def convert_file(file)
      base = File.basename(file, ".jp2")
      tpath = File.join(target, "#{base}.jpg")
      do_conversion(file, tpath)
    end

    def do_conversion(srcfile, tpath)
      `magick #{srcfile} #{tpath}`
    rescue
      logger.error(srcfile)
    end

    def copy_non_jp2s
      non_jp2s.each do |file|
        FileUtils.cp(File.join(source, file), File.join(target, file))
      end
    end

    def jp2s
      allfiles.select { |file| is_jp2?(file) }
        .map { |file| File.join(source, file) }
    end

    def non_jp2s
      allfiles.reject { |file| is_jp2?(file) }
        .map { |file| File.join(source, file) }
    end

    def is_jp2?(file)
      File.extname(file) == ".jp2"
    end
  end
end
