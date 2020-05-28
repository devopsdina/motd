# motd

motd custom resource - main objective is to move this into core chef.

## example usage

- create motd

```ruby
motd 'secure system messsage' do
  content 'this is a secure system. blah blah blah.'
end
```

- delete motd

```ruby
motd 'secure system messsage' do
  content 'this is a secure system. blah blah blah.'
  action :delete
end
```

- pass your own template to the motd (**only supported for Linux**)

```ruby
motd 'messsage' do
  source 'custom_motd.erb'
  cookbook 'motd'
end
```

## Supported Systems

```YAML
supports 'centos', '>= 6.0'
supports 'debian', '>= 8.0'
supports 'ubuntu', '>= 16.04'
supports 'windows'
```