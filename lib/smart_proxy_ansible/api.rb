require 'smart_proxy_ansible/roles_exporter'
require 'smart_proxy_ansible/files_exporter'

module Proxy
  module Ansible
    class Api < Sinatra::Base
      include ::Proxy::Log
      include ::Proxy::Helpers

      get '/roles' do
        roles = Proxy::Ansible::RolesExporter.new.export
        roles.to_json
      end

      get '/file/:role_name/:dir/:file_name' do |role_name, dir, file_name|
        begin
          file = Proxy::Ansible::FilesExporter.new(role_name, dir, file_name).export_file
          file.to_json
        rescue => e
          logger.debug e.backtrace.join("\n\t")
          log_halt 500, "Could not find requested file, #{e.message}"
        end
      end

      post '/file/:role_name/:dir/:file_name' do |role_name, dir, file_name|
        begin
          res = Proxy::Ansible::FilesExporter.new(role_name, dir, file_name).write_file(request.body.string)
          res.to_json
        rescue => e
          logger.debug e.backtrace.join("\n\t")
          log_halt 500, "Could not update requested file, #{e.message}"
        end
      end

      delete '/file/:role_name/:dir/:file_name' do |role_name, dir, file_name|
        begin
          res = Proxy::Ansible::FilesExporter.new(role_name, dir, file_name).delete_file
          res.to_json
        rescue => e
          logger.debug e.backtrace.join("\n\t")
          log_halt 500, "Could not delete requested file, #{e.message}"
        end
      end

      put '/file/:role_name/:dir/:file_name' do |role_name, dir, file_name|
        begin
          res = Proxy::Ansible::FilesExporter.new(role_name, dir, file_name).write_file(request.body.string)
          res.to_json
        rescue => e
          logger.debug e.backtrace.join("\n\t")
          log_halt 500, "Could not create requested file, #{e.message}"
        end
      end

      get '/roles/:role_name/variables' do |role_name|
        # not anything matching item, }}, {{, ansible_hostname or 'if'
        role_files = Dir.glob("/etc/ansible/roles/#{role_name}/**/*.yml")
        variables = role_files.map do |role_file|
          File.read(role_file).scan(/{{(.*?)}}/).select do |param|
            param.first.scan(/item/) == [] && param.first.scan(/if/) == []
          end.first
        end.compact
        variables.uniq!
        variables = variables.map(&:first).map(&:strip).to_json
      end
    end
  end
end
