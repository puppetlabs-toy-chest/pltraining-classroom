#! /opt/puppetlabs/puppet/bin/ruby
require 'colorize'
require 'puppet'
require 'puppetclassify'
require 'puppetdb'

Puppet.initialize_settings

# TODO: This makes me sad sad.
def pinned_nodes(rule)
  return [] unless rule
  return [] if rule.include? nil
  # select only toplevel rules of format name = value, then return the values as an array
  rule.select {|r| r[0] == '=' and r[1] == 'name' }.collect {|n| n[2] } rescue []
end

def matching_nodes(rule)
  return [] unless rule
  return [] if rule.include? nil
  begin
    $puppetdb.request('nodes', $classifier.rules.translate(rule)['query']).data
  rescue => e
    return []
  end
end

$classifier = PuppetClassify.new(
    "https://#{Puppet.settings[:server]}:4433/classifier-api",
    {
      "ca_certificate_path" => Puppet.settings[:cacert],
      "certificate_path"    => Puppet.settings[:hostcert],
      "private_key_path"    => Puppet.settings[:hostprivkey],
      "read_timeout"        => 90 # optional timeout, defaults to 90 if this key doesn't exist
    })

$puppetdb = PuppetDB::Client.new({
    :server => "https://#{Puppet.settings[:server]}:8081/pdb/query",
    :pem    => {
        'ca_file' => Puppet.settings[:cacert],
        'cert'    => Puppet.settings[:hostcert],
        'key'     => Puppet.settings[:hostprivkey],
    }}, 4)

environments = $classifier.environments.get_environments.collect { |env| env['name'] }
environments.reject! { |env| ["agent-specified", "production"].include? env }

results = {}
environments.each do |student|
  errors = []
  groups = $classifier.groups.get_groups.select {|env| env['environment'] == student }

  envgroups    = groups.select {|grp| grp['environment_trumps'] }
  parentgroups = groups.select {|grp| grp['parent'] == '00000000-0000-4000-8000-000000000000' and not grp['environment_trumps'] }
  childgroups  = groups - envgroups - parentgroups

  envpinned    = pinned_nodes(envgroups.first['rule'])
  parentpinned = pinned_nodes(parentgroups.first['rule'])

  envmatch    = matching_nodes(envgroups.first['rule'])
  parentmatch = matching_nodes(parentgroups.first['rule'])
  child1match = matching_nodes(["and", childgroups.first['rule'], envgroups.first['rule']])
  child2match = matching_nodes(["and", childgroups.last['rule'], envgroups.first['rule']])

  envpinwrong    = envpinned.reject { |n| n =~ /#{student}/ }
  parentpinwrong = parentpinned.reject { |n| n =~ /#{student}/ }

  envwrong     = envmatch.reject { |n| n['certname'] =~ /#{student}/ }.collect { |n| n['certname'] }
  parentwrong  = parentmatch.reject { |n| n['certname'] =~ /#{student}/ }.collect { |n| n['certname'] }
  child1wrong  = child1match.reject { |n| n['certname'] =~ /#{student}/ }.collect { |n| n['certname'] }
  child2wrong  = child2match.reject { |n| n['certname'] =~ /#{student}/ }.collect { |n| n['certname'] }

  # counting node groups
  errors << "Incorrect number of node groups (#{groups.size})" if groups.size != 4
  errors << "Incorrect number of environment groups (#{envgroups.size})" if envgroups.size != 1
  errors << "Incorrect number of parent classification groups (#{parentgroups.size})" if parentgroups.size != 1
  errors << "Incorrect number of child groups (#{childgroups.size})" if childgroups.size != 2

  # pinned nodes to env group
  errors << "Incorrect number of nodes pinned to the environment group (#{envpinned.size})" if envpinned.size != 2
  errors << "Wrong nodes pinned to env group: #{envpinwrong.inspect}" unless envpinwrong.empty?
  # nodes matching env group (should be the same as pinned)
  errors << "Incorrect number of nodes match the environment group (#{envmatch.size})" if envmatch.size != 2
  errors << "Wrong nodes matching env group: #{envwrong.inspect}" unless envwrong.empty?

  # pinned nodes to parent classification group
  errors << "Incorrect number of nodes pinned to the parent group (#{parentpinned.size})" if parentpinned.size != 2
  errors << "Wrong nodes pinned to parent group: #{parentpinwrong.inspect}" unless parentpinwrong.empty?
  # nodes matching parent classification group (should be the same as pinned)
  errors << "Incorrect number of nodes match the parent classification group (#{parentmatch.size})" if parentmatch.size != 2
  errors << "Wrong nodes matching parent group: #{parentwrong.inspect}" unless parentwrong.empty?

  # number of nodes matching child group 1
  errors << "Incorrect number of nodes match the '#{childgroups.first['name']}' group (#{child1match.size})" if child1match.size != 1
  errors << "Wrong nodes matching '#{childgroups.first['name']}' group: #{child1wrong.inspect}" unless child1wrong.empty?
  # number of nodes matching child group 2
  errors << "Incorrect number of nodes match the '#{childgroups.last['name']}' group (#{child2match.size})" if child2match.size != 1
  errors << "Wrong nodes matching '#{childgroups.last['name']}' group: #{child2wrong.inspect}" unless child2wrong.empty?

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
