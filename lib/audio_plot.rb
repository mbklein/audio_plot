require 'open3'
require 'mini_magick'

class AudioPlot

  LINES = [ 2.0/9,  5.0/12,  7.0/12, 13.0/18, 5.0/6, 11.0/12, 35.0/36, 1.0,
           16.0/9, 19.0/12, 17.0/12, 23.0/18, 7.0/6, 13.0/12, 37.0/36       ]

  class << self
    attr_accessor :ffmpeg

    def find_ffmpeg
      `which ffmpeg`.chomp
    end
  end
  self.ffmpeg = self.find_ffmpeg

  attr_reader :defaults

  def initialize(source, opts = {})
    @defaults = { start: 5, length: 10, width: 1280, height: 720, color: '#44db97', bgcolor: 'transparent' }.merge(opts)
    @source = source
  end

  def magick_cmd(opts = {})
    opts = @defaults.merge(opts)
    convert = MiniMagick::Tool::Convert.new
    convert.size(opts.values_at(:width,:height).join('x'))
    convert << 'canvas:none'
    convert.stroke("'#{opts[:color]}'")
    convert.draw(%{'rectangle 0,0 #{opts[:width]},#{opts[:height]}'})
    convert.fill(opts[:bgcolor])
    LINES.each do |line|
      pos = ((opts[:height]/2)*line).round
      convert.draw(%{'line 0,#{pos} 1280,#{pos}'})
    end
    convert << 'xc:transparent'
    convert << 'png:-'
    convert.command.join(' ')
  end

  def ffmpeg_cmd(opts = {})
    opts = @defaults.merge(opts)
    cmd = %{#{self.class.ffmpeg} -i "#{@source}" -i - }
    cmd << %{-filter_complex "[0:a]atrim=start=#{opts[:start]}:end=#{opts[:start]+opts[:length]},asetpts=PTS-STARTPTS,showwavespic=s=#{opts[:width]}x#{opts[:height]}:colors=#{opts[:color]}[fg],[1:v][fg]overlay=y=0" }
    cmd << %{-frames:v 1 -f image2pipe -c png -}
    cmd
  end

  def verify_commands!
    if self.class.ffmpeg.nil?
      raise "ffmpeg not found. Please set #{self.class.name}.ffmpeg = /path/to/ffmpeg"
    end
  end

  def run(opts = {})
    verify_commands!
    magick_o, magick_e, magick_s = Open3.capture3(magick_cmd(opts), binmode: true)
    ffmpeg_o, ffmpeg_e, ffmpeg_s = Open3.capture3(ffmpeg_cmd(opts), binmode: true, stdin_data: magick_o)
    raise ffmpeg_e.chomp unless ffmpeg_s.success?
    ffmpeg_o
  end
end
