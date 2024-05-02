# frozen_string_literal: true

require_relative "../misc_data_tools/image/jp2_to_jpg"

class Image < Thor
  def self.exit_on_failure? = true

  desc "jp2_to_jpg", "Converts jp2 files in source directory to jpg files in "\
    "target directory; copies all other files in source to target. Errors are "\
    "written to log.txt in target directory."
  method_option :source, aliases: "-s", desc: "Source directory path",
    required: true, type: :string
  method_option :target, aliases: "-t",
    desc: "Target directory path. If not provided, will be set to source with "\
    "`_conv` appended to directory name. If directory does not exist it will "\
    "be created",
    lazy_default: nil, required: false, type: :string
  def jp2_to_jpg
    Mdt::Jp2ToJpg.call(source: options[:source], target: options[:target])
  end
end
