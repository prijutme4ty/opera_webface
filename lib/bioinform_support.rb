module Bioinform
  class Error < StandardError
  end
  class PWM
    def round(n)
      PWM.new(matrix.map{|pos| pos.map{|x| x.round(n) } }).tap{|pwm| pwm.name = name}
    end
  end

  class PCM
    make_parameters :pseudocount
  end
  class PPM
    make_parameters :effective_count, :pseudocount
    def to_pcm
      PCM.new(matrix.map{|pos| pos.map{|el| el * effective_count} }).tap{|pcm| pcm.name = name}
    end
    def to_pwm
      pseudocount ? to_pcm.to_pwm(pseudocount) : to_pcm.to_pwm
    end
  end

  def self.get_pwm(data_model, matrix, background, pseudocount, effective_count)
    pm = Bioinform.const_get(data_model).new(matrix)
    pm.set_parameters(background: background)
    if pseudocount && ! pseudocount.blank? && [:PCM,:PPM].include?(data_model.to_sym)
      pm.set_parameters(pseudocount: pseudocount)
    end
    if effective_count && [:PPM].include?(data_model.to_sym)
      pm.set_parameters(effective_count: effective_count)
    end
    pm.to_pwm
  rescue => e
    raise "PWM creation failed (#{e})"
  end

  def self.get_pcm(data_model, matrix, effective_count)
    pm = Bioinform.const_get(data_model).new(matrix)
    if effective_count && [:PPM].include?(data_model.to_sym)
      pm.set_parameters(effective_count: effective_count)
    end
    pm.to_pcm
  end

  def self.get_ppm(data_model, matrix)
    Bioinform.const_get(data_model).new(matrix).to_ppm
  end

end
