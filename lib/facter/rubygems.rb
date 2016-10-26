Facter.add(:rubygems_version) do
  setcode 'gem --version'
end
