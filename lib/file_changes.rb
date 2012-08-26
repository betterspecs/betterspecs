require 'yaml'
require 'digest/sha1'

module MGutz

  # Tracks a file's last content change using SHA1 digest algorithm.
  #
  # File.mtime is not sufficient to detect if content has been updated. This
  # class will set `updated_at` if it detects a change in the content
  # irregardless of the file's mtime.
  #
  # Values are stored in `file_changes.yaml` by default.
  #
  class FileChanges
    def initialize(store_filename = "file_changes.yaml")
      @store_filename = store_filename

      if File.exists?(@store_filename)
        @changes = YAML.load_file(@store_filename)
      else
        @changes = {}
      end

    end

    # Gets a file's status change.
    #
    # filename - Name of the file
    # created_at - Optional. Use this date if change status not yet recorded.
    # content - Optional. Content of the file (if it has already been read).
    #
    # returns { :created_at => '', :updated_at => '', :digest = ''}
    #
    def status(filename, created_at = nil, content = nil)
      content ||= File.readlines(filename)
      digest = Digest::SHA1.hexdigest(content)
      item = @changes[filename.to_sym]

      if !item
        item = {}
        item[:created_at] = created_at || File.ctime(filename)
        item[:updated_at] = File.mtime(filename)
        item[:digest] = digest
        @changes[filename.to_sym] = item
        write_changes
      elsif item[:digest] != digest 
        item[:updated_at] = File.mtime(filename)
        item[:digest] = digest 
        write_changes
      end

      item
    end

  private

    def write_changes
      File.open(@store_filename, 'w') do |f|
        YAML.dump @changes, f 
      end
    end
  end
end

