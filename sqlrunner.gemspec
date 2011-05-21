require "rubygems"

Gem::Specification.new do |s|
  s.name = %q{sqlrunner}
  s.version = "0.0.1"
  s.authors = ["Elias Kugler"]
  s.email = %q{elias.kugler@gmail.com}
  s.files =   Dir["lib/**/*"] + Dir["bin/**/*"] + Dir["spec/**/*"]+ Dir["*.rb"] + ["MIT-LICENSE","sqlrunner.gemspec"]
  s.platform    = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "CHANGELOG.rdoc"]
  s.require_paths = ["lib"]
  s.summary = %q{SQLRunner }
  s.description = %q{Run SQL statements}
  s.files.reject! { |fn| fn.include? "CVS" }
  s.require_path = "lib"
  s.default_executable = %q{sqlrunner}
  s.executables = ["sqlrunner"]
  #s.homepage = %q{http://}
  #s.rubyforge_project = %q{}
  s.add_dependency("mail", ">= 2.2.1")
  s.add_dependency("log4r", ">=1.0.5")
  s.add_dependency("notes_mailer", ">= 0.0.1")
  #s.add_dependency("dbi", ">= 0.4.5")
  #s.add_dependency("dbd-odbc", ">= 0.2.5")
  #s.add_dependency("ruby-odbc")
end


#if $0 == __FILE__
#   Gem.manage_gems
#   Gem::Builder.new(spec).build
#end
