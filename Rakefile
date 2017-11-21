require 'puppetlabs_spec_helper/rake_tasks'

desc "Create PR to release branch"
task :release do
    `hub pull-request -h puppetlabs/education-builds:master -b puppetlabs/education-builds:release`
end

desc "Run spec tests without cleaning the fixtures directory"
task :cached_spec do
  Rake::Task[:spec_prep].invoke
  Rake::Task[:spec_standalone].invoke
end
