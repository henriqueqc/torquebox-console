# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{torquebox-console}
  s.version = IO.read(File.join(File.dirname(__FILE__), 'VERSION')).strip
  s.date = Time.now.strftime('%Y-%m-%d')
  s.authors = ["Lance Ball"]
  
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.description = %q{TorqueBox Console allows you to peer into the TorqueBox guts using a repl command line. You can view information about the components and applications you have running.}
  s.email = %q{lball@redhat.com}
  s.executables = ["tbconsole"]
  s.extra_rdoc_files = [
                        "README.md",
                        "LICENSE",
                        "TODO"
                       ]
  s.files = Dir[
                "[A-Z]*",
                "config/**/*",
                "lib/**/*",
                "bin/**/*"
               ] - %w{ Gemfile.lock }

  s.homepage = %q{http://github.com/torquebox/torquebox-console}
  s.licenses = ["AL"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.1}
  s.summary = %q{TorqueBox Console - A REPL commandline and information viewer for TorqueBox}


  deps = [
          [%q<jmx>, "= 0.9"],
          [%q<torquebox>, "~> 2.1.2"]
         ]
  
  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      deps.each do |name, version, dev|
        if dev
          s.add_development_dependency(name, [version])
        else
          s.add_runtime_dependency(name, [version])
        end
      end
    else
      deps.each do |name, version|
        s.add_dependency(name, [version])
      end
    end
  else
    deps.each do |name, version|
      s.add_dependency(name, [version])
    end
  end
end

