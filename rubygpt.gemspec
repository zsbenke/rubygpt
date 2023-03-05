# frozen_string_literal: true

require_relative "lib/rubygpt/version"

Gem::Specification.new do |spec|
  spec.name = "rubygpt"
  spec.version = Rubygpt::VERSION
  spec.authors = ["Zsolt Benke"]
  spec.email = ["zsolt@decoding.io"]

  spec.summary = "Interact with ChatGPT from the command-line"
  spec.homepage = "https://decoding.io"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "ruby-openai"
  spec.add_dependency "colorize"
  spec.add_dependency "clipboard"
  spec.add_dependency "tty-markdown"
  spec.add_dependency "awesome_print"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
