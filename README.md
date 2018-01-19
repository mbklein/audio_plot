# AudioPlot

## Purpose

Generate waveform plots of audio data using [ffmpeg](http://ffmpeg.org/) and
(optionally) [ImageMagick](http://www.imagemagick.org/)/[GraphicsMagick](http://www.graphicsmagick.org/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'audio_plot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install audio_plot

## Usage

    ap = AudioPlot.new('/path/to/audio/file')
    image_data = ap.run
    File.open('waveform.png','wb') { |f| f.write(image_data) }

Both `AudioPlot.new` and `AudioPlot#run` take a number of optional parameters:

* `start` - The start time (in seconds) from which to generate the plot (default: `5`)
* `length` - The length (in seconds) of the plot (default: `10`)
* `width` - The width (in pixels) of the plot (default: `1280`)
* `height` - The height (in pixels) of the plot (default: `720`)
* `color` - The color of the waveform and gridlines (default: `#44db97`)
* `bg` - Whether to generate to a background grid behind thhe plot (default: `true` if ImageMagick or GraphicsMagick is installed)
* `bgcolor` - The background color for the plot (default: `transparent`)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/audio_plot.

## License

The gem is available as open source under the terms of the [Apache 2 License](https://opensource.org/licenses/Apache-2.0).
