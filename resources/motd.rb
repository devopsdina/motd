resource_name :motd

default_action :create

property :content, String, required: true

action :create do
  if platform_family?('windows')
    # windows motd settings
    registry_key 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\policies\system' do
      values [
              { name: 'legalnoticecaption', type: :string, data: new_resource.name.to_s },
              { name: 'legalnoticetext', type: :string, data: new_resource.content.to_s },
             ]
      action :create
    end
  else
    permissions = '0644'
    target = '/etc/motd'

    # is this machine using update-motd?
    update_motd = (::File.directory? '/etc/update-motd.d')

    if update_motd || platform_family?('debian')
      permissions = '0755'
    end

    if platform_family?('debian')
      version_9 = node[platform_version].to_f >= 9.0

      template '/etc/pam.d/sshd' do
        source 'sshd.erb'
        variables(
          debian_version_9: version_9
        )
        mode permissions
        action :create
      end
    end

    template target do
      source 'motd.erb'
      variables(
        motd_content: new_resource.content.to_s
      )
      mode permissions
      action :create
    end
  end
end
