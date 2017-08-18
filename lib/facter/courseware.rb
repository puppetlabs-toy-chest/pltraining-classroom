Facter.add('latest_courseware') do
  setcode do
    next unless File.directory? '/var/cache/showoff/courseware/.git'

    versions = {}
    Dir.chdir('/var/cache/showoff/courseware') do
      `git tag`.each_line do |line|
        next unless line.match(/^(\w+)-v(\d.\d.\d)$/)
        name, version = Regexp.last_match[1..2]

        versions[name] ||= []
        versions[name]  << Gem::Version.new(version)
      end

      versions.each do |course, list|
        versions[course] = list.max.to_s
      end
    end

    versions
  end
end
