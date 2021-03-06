require 'open3'
require 'mini_magick'

##
# Class that wraps ImageMagick/GraphicsMagick and ffmpeg to generate
# a single-frame waveform PNG from an audio file.
#
# @example
#   ap = AudioPlot.new('/path/to/source.m4a', start: 2, length: 5, color: 'red')
#   File.open('waveform.png','wb') { |file| file.write(ap.run) }
#
class AudioPlot
  class << self
    attr_accessor :ffmpeg

    def magick?
      MiniMagick.cli
    rescue MiniMagick::Error
      false
    end
  end
  self.ffmpeg = `which ffmpeg`.chomp

  attr_reader :defaults

  def initialize(source, opts = {})
    @defaults = { start: 5, length: 10, width: 1280, height: 720,
                  color: '#44db97', bg: self.class.magick?, bgcolor: 'transparent' }.merge(opts)
    @source = source
  end

  def run_magick(opts = {})
    out, _err, _status = Open3.capture3(magick_cmd(opts), binmode: true)
    out
  end

  def run(opts = {})
    verify_commands!
    opts = @defaults.merge(opts)
    bg = opts[:bg] && self.class.magick? ? run_magick(opts) : nil
    out, err, status = Open3.capture3(ffmpeg_cmd(opts), binmode: true, stdin_data: bg)
    raise err.chomp unless status.success?
    out
  end

  private

  def background_pattern
    [8, 15, 21, 26, 30, 33, 35, 36, 37, 39, 42, 46, 51, 57, 64].map { |l| l.to_f / 36 }
  end

  # rubocop:disable Metrics/AbcSize
  def magick_cmd(opts = {})
    convert = MiniMagick::Tool::Convert.new
    convert.size(opts.values_at(:width, :height).join('x'))
    convert << 'canvas:none'
    convert.stroke(%('#{opts[:color]}'))
    convert.fill(%('#{opts[:bgcolor]}'))
    convert.draw(%('rectangle 0,0 #{opts[:width]},#{opts[:height]}'))
    background_pattern.each do |line|
      pos = ((opts[:height] / 2) * line).round
      convert.draw(%('line 0,#{pos} 1280,#{pos}'))
    end
    convert << 'xc:transparent'
    convert << 'png:-'
    convert.command.join(' ')
  end

  def ffmpeg_cmd(opts = {})
    cmd = %(#{self.class.ffmpeg} -i "#{@source}" )
    bg_source = if opts[:bg] && self.class.magick?
      %(-i - )
    elsif opts[:bgcolor] != 'transparent'
      %(-f lavfi -i "color=s=#{opts[:width]}x#{opts[:height]}:c=#{opts[:bgcolor]}" )
    else
      nil
    end

    cmd << bg_source.to_s
    cmd << %(-filter_complex )
    cmd << %("[0:a]atrim=start=#{opts[:start]}:end=#{opts[:start] + opts[:length]},)
    cmd << %(asetpts=PTS-STARTPTS,showwavespic=s=#{opts[:width]}x#{opts[:height]}:colors=#{opts[:color]})
    cmd << %([fg],[1:v][fg]overlay=y=0) unless bg_source.nil?
    cmd << %(" -frames:v 1 -f image2pipe -c png -)
    cmd
  end
  # rubocop:enable Metrics/AbcSize

  def verify_commands!
    return unless self.class.ffmpeg.nil?
    err = "ffmpeg not found. Please set #{self.class.name}.ffmpeg = /path/to/ffmpeg"
    raise err
  end
end
