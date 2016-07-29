require 'smart_proxy_ansible/exporter'
require 'fileutils'

module Proxy::Ansible
  class FilesExporter < Exporter
    attr_reader :filepath

    def initialize(role_name, dir, file_name)
      super()
      @filepath = "#{roles_dir}/#{role_name}/#{dir}/#{file_name}"
    end

    def export_file
      { :content => File.read(filepath) }
    end

    def write_file(content)
      File.write(filepath, content)
      { :file => filepath, :file_written => true }
    end

    def delete_file
      FileUtils.rm(filepath)
      { :file => filepath, :deleted => true }
    end
  end
end