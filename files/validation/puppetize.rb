#! /opt/puppetlabs/puppet/bin/ruby
require 'colorize'
require 'puppet'
require 'puppetclassify'
require 'puppetdb'

Puppet.initialize_settings

def pinned_nodes(rule)
  return nil unless rule.shift == 'or'

  nodes = rule.collect do |item|
    item[2] if (item[0] == '=' and item[1] == 'name')
  end

  nodes unless nodes.include? nil
end

classifier = PuppetClassify.new(
    "https://#{Puppet.settings[:server]}:4433/classifier-api",
    {
      "ca_certificate_path" => Puppet.settings[:cacert],
      "certificate_path"    => Puppet.settings[:hostcert],
      "private_key_path"    => Puppet.settings[:hostprivkey],
      "read_timeout"        => 90 # optional timeout, defaults to 90 if this key doesn't exist
    })

puppetdb = PuppetDB::Client.new({
    :server => "https://#{Puppet.settings[:server]}:8081/pdb/query",
    :pem    => {
        'ca_file' => Puppet.settings[:cacert],
        'cert'    => Puppet.settings[:hostcert],
        'key'     => Puppet.settings[:hostprivkey],
    }}, 4)

environments = classifier.environments.get_environments.collect { |env| env['name'] }
environments.reject! { |env| ["agent-specified", "production"].include? env }

results = {}
environments.each do |student|
  errors = []
  groups = classifier.groups.get_groups.select {|env| env['environment'] == student }

  envgroups    = groups.select {|grp| grp['environment_trumps'] }
  parentgroups = groups.select {|grp| grp['parent'] == '00000000-0000-4000-8000-000000000000' and not grp['environment_trumps'] }
  childgroups  = groups - envgroups - parentgroups

  child1rule   = ["and", childgroups.first['rule'], envgroups.first['rule']]
  child2rule   = ["and", childgroups.last['rule'], envgroups.first['rule']]

  envpinned    = puppetdb.request('nodes', classifier.rules.translate(envgroups.first['rule'])['query']).data rescue []
  parentpinned = puppetdb.request('nodes', classifier.rules.translate(parentgroups.first['rule'])['query']).data rescue []
  child1pinned = puppetdb.request('nodes', classifier.rules.translate(child1rule)['query']).data rescue []
  child2pinned = puppetdb.request('nodes', classifier.rules.translate(child2rule)['query']).data rescue []

  envwrong     = envpinned.reject { |n| n['certname'] =~ /#{student}/ }.collect { |n| n['certname'] }
  parentwrong  = parentpinned.reject { |n| n['certname'] =~ /#{student}/ }.collect { |n| n['certname'] }
  child1wrong  = child1pinned.reject { |n| n['certname'] =~ /#{student}/ }.collect { |n| n['certname'] }
  child2wrong  = child2pinned.reject { |n| n['certname'] =~ /#{student}/ }.collect { |n| n['certname'] }

  errors << "Incorrect number of node groups (#{groups.size})" if groups.size != 4
  errors << "Incorrect number of environment groups (#{envgroups.size})" if envgroups.size != 1
  errors << "Incorrect number of parent classification groups (#{parentgroups.size})" if parentgroups.size != 1
  errors << "Incorrect number of child groups (#{childgroups.size})" if childgroups.size != 2

  errors << "Incorrect number of nodes match the environment group (#{envpinned.size})" if envpinned.size != 2
  errors << "Wrong nodes in env group: #{envwrong.inspect}" unless envwrong.empty?

  errors << "Incorrect number of nodes match the parent classification group (#{parentpinned.size})" if parentpinned.size != 2
  errors << "Wrong nodes in parent group: #{parentwrong.inspect}" unless parentwrong.empty?

  errors << "Incorrect number of nodes match the '#{childgroups.first['name']}' group (#{child1pinned.size})" if child1pinned.size != 1
  errors << "Wrong nodes in '#{childgroups.first['name']}' group: #{child1wrong.inspect}" unless child1wrong.empty?

  errors << "Incorrect number of nodes match the '#{childgroups.last['name']}' group (#{child2pinned.size})" if child2pinned.size != 1
  errors << "Wrong nodes in '#{childgroups.last['name']}' group: #{child2wrong.inspect}" unless child2wrong.empty?

  results[student] = errors
end

results.each do |student, errors|
  if errors.empty?
    printf("* %-71s %s\n", student, '[OK]'.green)
  else
    printf("* %-70s %s\n", student, '[FAIL]'.red)
    errors.each do |error|
      puts "   - #{error}".yellow
    end
  end
end
