module SequenceLogoGenerator
  def self.run(pcm_files:, output_folder:, orientation: 'both', x_unit: 30, y_unit: 60, additional_options: [])
    return  if pcm_files.empty?

    FileUtils.mkdir_p(output_folder)  unless Dir.exist?(output_folder)

    opts = []
    opts += ['--logo-folder', output_folder]
    opts += ['--orientation', orientation]
    opts += ['--x-unit', x_unit.to_s]
    opts += ['--y-unit', y_unit.to_s]
    opts += additional_options.flatten.map(&:to_s)

    Open3.popen2('sequence_logo', *opts){|fread, fwrite|
      fread.puts Shellwords.join(pcm_files)
      fread.close
    }
  end

  def self.run_dinucleotide(pcm_files:, output_folder:, orientation: 'both', x_unit: 30, y_unit: 60)
    return  if pcm_files.empty?

    FileUtils.mkdir_p(output_folder)  unless Dir.exist?(output_folder)

    ['direct', 'revcomp'].each do |orient|
      next  unless orientation == 'both' || orientation == orient
      pcm_files.each do |pcm_file|
        basename = File.basename(pcm_file, File.extname(pcm_file))
        output_file = File.join(output_folder, "#{basename}_#{orient}.png")
        opts = [x_unit.to_s, y_unit.to_s]
        opts << '--revcomp'  if orient == 'revcomp'
        system 'ruby', File.absolute_path('pmflogo/dpmflogo3.rb', __dir__), pcm_file, output_file, *opts
      end
    end
  end


  DefaultSizes = {
    big: {x_unit: 30, y_unit: 60},
    small: {x_unit: 15, y_unit: 30},
    small_for_long_models: {x_unit: 10, y_unit: 20},
  }
  LongModelThreshold = 20
end