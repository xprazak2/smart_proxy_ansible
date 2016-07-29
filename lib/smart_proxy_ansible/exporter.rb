module Proxy::Ansible
  class Exporter
    attr_reader :roles_dir

    def initialize
      @roles_dir = Proxy::Ansible::Plugin.settings.roles_dir
    end
  end
end
