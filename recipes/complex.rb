#
# Cookbook:: motd
# Recipe:: complex
#
# Copyright:: 2020, The Authors, All Rights Reserved.

motd 'messsage' do
  source 'custom_motd.erb'
  cookbook 'motd'
end
