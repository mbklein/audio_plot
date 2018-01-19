
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "audio_plot/version"

Gem::Specification.new do |spec|
  spec.name          = "audio_plot"
  spec.version       = AudioPlot::VERSION
  spec.authors       = ["Michael Klein"]
  spec.email         = ["mbklein@gmail.com"]

  spec.summary       = %q{Generate a waveform bitmap from an audio file}
  spec.description   = %q{Generate a waveform bitmap from an audio file}
  spec.homepage      = "https://github.com/mbklein/audio_plot"
  spec.license       = "Apache2"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mini_magick"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
