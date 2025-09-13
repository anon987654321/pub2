#!/usr/bin/env ruby
# frozen_string_literal: true

#
# IMPORTANT: gem install --user-install ruby-vips tty-prompt && export GEM_HOME=$HOME/.gem/ruby/3.3 GEM_PATH=$HOME/.gem/ruby/3.3:$GEM_PATH PATH=$HOME/.gem/ruby/3.3/bin:$PATH

require 'vips'
require 'logger'
require 'tty-prompt'
require 'time'

# Logging setup
$logger = Logger.new('postpro.log')
$logger.level = Logger::DEBUG

$cli_logger = Logger.new(STDOUT)
$cli_logger.level = Logger::INFO

PROMPT = TTY::Prompt.new

# Map effect names to their method symbols
EFFECTS = {
  film_grain: :film_grain,
  light_leaks: :light_leaks,
  lens_distortion: :lens_distortion,
  sepia: :sepia,
  bleach_bypass: :bleach_bypass,
  lomo: :lomo,
  golden_hour_glow: :golden_hour_glow,
  cross_process: :cross_process,
  bloom_effect: :bloom_effect,
  film_halation: :film_halation,
  teal_and_orange: :teal_and_orange,
  day_for_night: :day_for_night,
  anamorphic_simulation: :anamorphic_simulation,
  chromatic_aberration: :chromatic_aberration,
  vhs_degrade: :vhs_degrade,
  color_fade: :color_fade
}

def random_effects(count)
  EFFECTS.keys.sample(count)
end

def adjust_intensity(image, base_intensity)
  size_factor = Math.sqrt(image.width * image.height) / 1000.0
  (base_intensity * size_factor).clamp(0.5, 3.0)
end

def apply_effects(image, effects_array)
  effects_array.each do |effect_name|
    method_sym = EFFECTS[effect_name]
    next unless respond_to?(method_sym, true)

    intensity = adjust_intensity(image, 1.0)
    $cli_logger.info "Applied effect: #{effect_name} (intensity: #{intensity.round(2)})"
    image = send(method_sym, image, intensity)
  end
  image
end

def apply_effects_from_recipe(image, recipe)
  recipe.each do |effect, intensity|
    method_sym = EFFECTS[effect.to_sym]
    next unless respond_to?(method_sym, true)

    $cli_logger.info "Applied effect: #{effect} (intensity: #{intensity})"
    image = send(method_sym, image, intensity.to_f)
  end
  image
end

# --- Effects ---

def film_grain(image, intensity)
  noise = Vips::Image.gaussnoise(image.width, image.height, mean: 128, sigma: 30 * intensity)
  (image + noise).clamp(0, 255)
end

def light_leaks(image, intensity)
  overlay = Vips::Image.black(image.width, image.height)
  overlay = overlay.draw_circle([255 * intensity, 50 * intensity, 0],
                                image.width / 3, image.height / 3,
                                image.width / 4, fill: true)
  image.composite2(overlay, 'add')
end

def lens_distortion(image, intensity)
  identity = Vips::Image.identity(image.width, image.height)
  image.mapim(identity.linear([1.0 + (0.2 * intensity)], [0]))
end

def sepia(image, intensity)
  matrix = [
    0.393 * intensity, 0.769 * intensity, 0.189 * intensity,
    0.349 * intensity, 0.686 * intensity, 0.168 * intensity,
    0.272 * intensity, 0.534 * intensity, 0.131 * intensity
  ]
  image.recomb(matrix)
end

def bleach_bypass(image, intensity)
  gray = image.colourspace('b-w')
  blend = ((image * 0.5) + (gray * 0.5)) * intensity
  (image + blend).clamp(0, 255)
end

def lomo(image, intensity)
  saturated = image * (1.0 + (0.1 * intensity))
  vignette = Vips::Image.black(image.width, image.height)
  vignette = vignette.draw_circle(128, image.width / 2, image.height / 2, image.width / 2, fill: true)
  saturated.composite2(vignette, 'multiply')
end

def golden_hour_glow(image, _intensity)
  overlay = Vips::Image.black(image.width, image.height)
  overlay = overlay.draw_circle([255, 200, 150],
                                image.width / 2, image.height / 2,
                                image.width / 3, fill: true)
  image.composite2(overlay, 'add')
end

def cross_process(image, intensity)
  # If intensity > 0.5, invert the image for dramatic effect
  image.invert if intensity > 0.5
  image
end

def bloom_effect(image, intensity)
  blur1 = image.gaussblur(5 * intensity)
  blur2 = image.gaussblur(10 * intensity)
  combined = ((blur1 * 0.6) + (blur2 * 0.4)) * intensity
  (image + combined).clamp(0, 255)
end

def film_halation(image, intensity)
  highlights = image.more(220)
  halo = highlights.gaussblur(15 * intensity).linear(0.1 * intensity, 0)
  (image + halo).clamp(0, 255)
end

def teal_and_orange(image, intensity)
  matrix = [
    0.9, 0.1, 0.0,
    0.0, 0.8, 0.2,
    0.1, 0.2, 0.7
  ]
  image.recomb(matrix).linear(intensity, 0).clamp(0, 255)
end

def day_for_night(image, intensity)
  darkened = image.linear(1.0 - (0.3 * intensity), 0).clip(0, 255)
  darkened.add([0, 0, 60 * intensity]).clip(0, 255)
end

def anamorphic_simulation(image, intensity)
  image.resize(1.0 + (0.1 * intensity), vscale: 1.0)
end

def chromatic_aberration(image, intensity)
  r, g, b = image.bandsplit
  r = r.roll(intensity, 0)
  b = b.roll(-intensity, 0)
  Vips::Image.bandjoin([r, g, b])
end

def vhs_degrade(image, intensity)
  noise = Vips::Image.gaussnoise(image.width, image.height, sigma: 50 * intensity)
  lines = Vips::Image.sines(image.width, image.height).linear(0.3, 128)
  (image + noise - lines).clip(0, 255)
end

def color_fade(image, intensity)
  image.linear(1 - intensity, 128 * intensity).clip(0, 255)
end

# --- Main Interactive Workflow ---

def main
  apply_random = PROMPT.yes?('Apply a random combination of effects?')
  recipe_file = PROMPT.ask('Load a custom effects recipe JSON? (filename):', default: '')

  patterns = PROMPT.ask('Enter file patterns (default: **/*.jpg, **/*.jpeg, **/*.png, **/*.webp):', default: '')
  file_patterns = patterns.strip.split(',')
  file_patterns = ['**/*.jpg', '**/*.jpeg', '**/*.png', '**/*.webp'] if file_patterns.empty?

  variations = PROMPT.ask('How many variations per image? (default: 3):', convert: :int, default: '3').to_i

  $cli_logger.info 'Starting image processing...'
  files = file_patterns.flat_map { |pattern| Dir.glob(pattern.strip) }
  if files.empty?
    $cli_logger.error 'No files matched the pattern!'
    return
  end

  recipe = nil
  if !recipe_file.empty? && File.exist?(recipe_file)
    recipe = JSON.parse(File.read(recipe_file))
    $cli_logger.info "Loaded recipe from #{recipe_file}"
  end

  files.each do |file|
    next if File.basename(file).include?('processed')

    begin
      $cli_logger.info "Processing file: #{file}"
      image = Vips::Image.new_from_file(file)

      processed_image = if recipe
                          apply_effects_from_recipe(image, recipe)
                        elsif apply_random
                          selected = random_effects(3)
                          apply_effects(image, selected)
                        else
                          $cli_logger.warn 'No effects selected. Skipping file.'
                          next
                        end

      variations.times do |i|
        timestamp = Time.now.strftime('%Y%m%d%H%M%S')
        output_file = file.sub(File.extname(file), "_processed_v#{i + 1}_#{timestamp}#{File.extname(file)}")
        processed_image.write_to_file(output_file)
        $cli_logger.info "Saved variation #{i + 1} as #{output_file}"
      end
    rescue StandardError => e
      $cli_logger.error "Error processing #{file}: #{e.message}"
      $cli_logger.error e.backtrace.join("\n")
    end
  end

  $cli_logger.info 'Processing completed.'
end

main if __FILE__ == $0