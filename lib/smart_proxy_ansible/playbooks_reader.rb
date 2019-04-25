require_relative 'exception'
require 'yaml'


module Proxy
  module Ansible
    class PlaybooksReader
      include Proxy::Ansible::Utils

      def read_playbooks(path)
        files = Dir.glob("#{path}/**/*.yml") + Dir.glob("#{path}/**/*.yaml")
        files.reduce({ :warnings => [], :errors => [], :playbooks => []}) do |memo, file|
          read_playbook_file file, memo
        end
      end

      def read_playbook_file(file, result)
        name = file.split('/').last
        playbook = File.read file
        result.tap { |res| res[:playbooks] << { :name => name, :content => playbook } }
      rescue => e
        result.tap { |res| res[:warnings] << e.message }
      end
    end
  end
end
