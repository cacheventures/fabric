require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << 'tests'
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
  t.warning = false
end

task :default => :test
