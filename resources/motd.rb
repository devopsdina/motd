resource_name :motd
provides :motd

property :content, String
property :source, String # use only if content is not provided; LINUX ONLY
property :cookbook, String # use only if content is not provided; LINUX ONLY

action :create do
  if platform_family?('windows')
    if new_resource.source || new_resource.cookbook
      Chef::Log.fatal('Windows does not support custom motd templates')
      raise 'Windows only supports the content property'
    end
    # windows motd settings
    registry_key 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system' do
      values [
              { name: 'legalnoticecaption', type: :string, data: new_resource.name.to_s },
              { name: 'legalnoticetext', type: :string, data: new_resource.content.to_s },
             ]
      action :create
    end
  else
    if new_resource.source && new_resource.content
      Chef::Log.fatal('content and source are mutually exclusive')
      raise 'Use the content property OR source property'
    end

    permissions = '0644'

    # is this machine using update-motd?
    update_motd = (::File.directory? '/etc/update-motd.d')

    if update_motd || platform_family?('debian')
      permissions = '0755'
    end

    if platform_family?('debian')
      # For debian systems, comment out pam_motd.so noupdate from sshd for motd to appear only once.
      filepath = '/etc/pam.d/sshd'
      raise "File #{filepath} not found" unless ::File.exist?(filepath)
      search = /^session    optional     pam_motd.so noupdate/
      replace = '# session    optional     pam_motd.so noupdate # COMMENTED OUT BY CHEF'
      current_file = Chef::Util::FileEdit.new(filepath)
      current_file.search_file_replace_line(search, replace)
      current_file.write_file
    end

    if new_resource.source
      template '/etc/motd' do
        source new_resource.source
        cookbook new_resource.cookbook
        mode permissions
        action :create
      end
    else
      template '/etc/motd' do
        source 'motd.erb'
        variables(
          motd_content: new_resource.content.to_s
        )
        mode permissions
        action :create
      end
    end
  end
end

action :delete do
  if platform_family?('windows')
    registry_key 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system' do
      values [
              { name: 'legalnoticecaption', type: :string, data: new_resource.name.to_s },
              { name: 'legalnoticetext', type: :string, data: new_resource.content.to_s },
             ]
      action :delete
    end
  else
    file '/etc/motd' do
      action :delete
    end
  end
end
