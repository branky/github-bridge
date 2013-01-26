
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name     'github-bridge'
  authors  'Branky Shao'
  email    'branky34@gmail.com'
  url      'http://github.com/branky/github-bridge'
}

