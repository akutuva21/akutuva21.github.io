require "rake"
require "rbconfig"

RUBY_TEST_FILES = FileList["test/test_*.rb", "spec/**/*_spec.rb"]

task :test do
  RUBY_TEST_FILES.each do |test_file|
    sh RbConfig.ruby, test_file
  end
end

task default: :test
