# Postpro.rb – Analog and Cinematic Post-Processing

Version: 13.3.14  
Last Modified: 2025-04-04T14:00:00Z  
Author: PubHealthcare  

---

Imagine a world where every digital image can transcend its sterile origins, reborn as a visceral artifact of analog nostalgia or a chaotic masterpiece of experimental abstraction. Postpro.rb is your portal to that realm—an interactive CLI tool that harnesses the raw power of libvips and ruby-vips to infuse your photos with soul, unpredictability, and cinematic depth. Whether you crave the subtle warmth of a Kodachrome slide or the frenetic energy of a glitched VHS tape, this script delivers infinite, truly random variations that keep the original motive alive while pushing creative boundaries to the edge.

---

## Key Features

1. True Random Variations  
   - Every output is a unique snowflake, with effects and intensities reshuffled and recalibrated per run.  
   - No repetition, just pure creative chaos or refined subtlety, tailored to your mode.

2. Dual Creative Modes  
   - Professional Mode: A gentle nod to analog film, with delicate grain, scratches, and tones that whisper authenticity.  
   - Experimental Mode: A wild ride of VHS degradation, parametric distortions, and abstract patterns, balanced to preserve the image’s heart.

3. Layered Effects Engine  
   - Stack over 25 effects with dynamic, randomized intensities for endless possibilities.  
   - From retro film to futuristic glitches, each layer builds a story.

4. Interactive CLI Workflow  
   - Choose random effects or load precise JSON recipes.  
   - Batch-process recursively with flexible file patterns (e.g., *.jpg, **/*.png).

5. High-Performance Backbone  
   - Powered by libvips, ensuring swift processing even for large images with minimal memory overhead.

---

## Installation

1. Install libvips  
   - OpenBSD: Execute "doas pkg_add -U vips" to install the latest version.  
   - Ubuntu/Debian: Use "apt-get install libvips" for system-wide setup.  
   - macOS: Run "brew install vips" via Homebrew.

2. Install Ruby Gems  
   - Run "gem install --user-install ruby-vips tty-prompt" to fetch dependencies.

### OpenBSD Setup (Critical)  
To ensure libvips works seamlessly:  
   - Set the library path with "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" to avoid "not found" errors.  
   - Configure your gem environment (adjust for your Ruby version, e.g., 3.3):  
     - "export GEM_HOME=$HOME/.gem/ruby/3.3"  
     - "export GEM_PATH=$HOME/.gem/ruby/3.3:$GEM_PATH"  
     - "export PATH=$HOME/.gem/ruby/3.3/bin:$PATH"

---

## Example Usage

Run the script:  
   - "ruby postpro.rb"  
You’ll see:  
   - "Postpro.rb v13.3.14 - Transform your images with analog and cinematic flair!"  
   - Professional mode? (Yes for subtle, No for bold experimental) [Y/n]: n  
   - Apply random effects? (No for custom recipe) [Y/n]: y  
   - Custom JSON recipe file (or press Enter for none): [Enter]  
   - File patterns (e.g., *.jpg, w.jpg; default: **/*.{jpg,jpeg,png,webp}): w.jpg  
   - Number of variations per image (1-5): 3  
   - Effects per variation (1-5): 3  

Output might look like:  
   - "Processing 1 file..."  
   - "Saved variation 1 as w_processed_v1_20250404142345.jpg, avg: 120.5, change: 18.0"  
   - "Saved variation 2 as w_processed_v2_20250404142346.jpg, avg: 135.2, change: 32.7"  
   - "Saved variation 3 as w_processed_v3_20250404142347.jpg, avg: 115.8, change: 13.3"  
   - "Completed: 1 file processed, 3 variations created"  

- Professional Mode delivers subtle, film-like enhancements.  
- Experimental Mode unleashes chaotic, unique distortions.  
- Each variant is distinct, with the original motive still shining through.

---

## Effects and Techniques: Deep Dive

Here’s an exhaustive breakdown of key effects and the special techniques that make them tick, reflecting their behavior in v13.3.14:

### film_grain  
- **Purpose**: Adds a textured noise layer mimicking high-ISO film stocks.  
- **Technique**: Uses Vips::Image.gaussnoise to generate randomized noise with a sigma value (20 in professional, 40 in experimental). A random density factor (0.5 to 1.0) varies grain intensity per pixel, preventing the static "silk cheat" look. Blended at 0.2 opacity to keep the original image prominent.  
- **Modes**: Subtle and sparse in professional; denser and more dynamic in experimental.  

### light_leaks  
- **Purpose**: Simulates camera light streaks with warm, organic overlays.  
- **Technique**: Draws random circles (2 in pro, 4-8 in exp) with variable radii and colors (e.g., 255, 150-200, 50-100 in experimental). Applies a gaussian blur (10 in pro, 15-25 in exp) for softness. Blended at 0.3 opacity for a gentle glow.  
- **Modes**: Minimal and warm in pro; erratic and vivid in exp.  

### lens_distortion  
- **Purpose**: Emulates vintage lens warping with subtle or wild bends.  
- **Technique**: Creates a displacement map using Vips::Image.identity, scaled by a factor (0.1 in pro, 0.3-0.7 in exp) and random offsets (2-5). Maps the image via Vips::Image.mapim for a curved effect.  
- **Modes**: Slight curve in pro; exaggerated warp in exp.  

### sepia  
- **Purpose**: Infuses a classic brown-toned vintage look.  
- **Technique**: Applies a recombination matrix with randomized shift (0.1 in pro, 0.2 in exp) to adjust warmth and tone balance, cast to uchar for 8-bit output.  
- **Modes**: Soft and natural in pro; slightly richer in exp.  

### bleach_bypass  
- **Purpose**: Creates a high-contrast, desaturated cinematic style.  
- **Technique**: Blends the image with its greyscale version (grey16 colorspace) using a random blend factor (0.4 in pro, 0.6-0.9 in exp), then boosts contrast with a linear transform.  
- **Modes**: Controlled fade in pro; stark contrast in exp.  

### lomo  
- **Purpose**: Adds vivid saturation with a vignette edge.  
- **Technique**: Increases saturation via linear scaling (0.2 in pro, 0.4-0.7 in exp), then overlays a random-intensity vignette circle (150-200). Blended additively at 0.3 opacity.  
- **Modes**: Gentle pop in pro; bold and vignetted in exp.  

### golden_hour_glow  
- **Purpose**: Mimics the warm, diffused light of sunset.  
- **Technique**: Draws a central circle with random warm colors (e.g., 255, 180-220, 150-180 in exp), blurred (8 in pro, 10-20 in exp) and blended at 0.3 opacity for a soft glow.  
- **Modes**: Subtle warmth in pro; radiant burst in exp.  

### cross_process  
- **Purpose**: Shifts colors for a film-like chemical effect.  
- **Technique**: Splits RGB bands, applies random linear shifts (e.g., 0.3-0.6 red in exp), and recombines with variable offsets (10-20 red, -5 to -10 blue).  
- **Modes**: Mild shift in pro; dramatic hue swap in exp.  

### bloom_effect  
- **Purpose**: Adds a dreamy glow around highlights.  
- **Technique**: Boosts brightness (1.5 in pro, 2.0-3.0 in exp), blurs with a random radius (8-15), and blends at 0.3 opacity.  
- **Modes**: Soft halo in pro; intense bloom in exp.  

### film_halation  
- **Purpose**: Simulates light halos around bright areas.  
- **Technique**: Masks highlights above a random threshold (180-220), blurs (6 in pro, 10-15 in exp), and blends at 0.3 opacity with band replication.  
- **Modes**: Faint glow in pro; pronounced halos in exp.  

### teal_and_orange  
- **Purpose**: Applies cinematic color grading.  
- **Technique**: Splits RGB, shifts red (0.15 in pro, 0.3-0.5 in exp), green, and blue with random offsets, then recombines.  
- **Modes**: Subtle grading in pro; vivid contrast in exp.  

### day_for_night  
- **Purpose**: Turns day scenes into night with a blue tint.  
- **Technique**: Darkens with a random factor (0.3 in pro, 0.5-0.8 in exp), boosts blue (0.1 in pro, 0.2-0.4 in exp) with random offsets.  
- **Modes**: Gentle tint in pro; deep night in exp.  

### anamorphic_simulation  
- **Purpose**: Mimics widescreen lens stretch.  
- **Technique**: Resizes horizontally (0.1 in pro, 0.2-0.4 in exp) with random vertical scaling (0.9-1.1) for distortion.  
- **Modes**: Slight stretch in pro; extreme warp in exp.  

### chromatic_aberration  
- **Purpose**: Adds color fringing for a retro lens effect.  
- **Technique**: Shifts red and blue bands by random amounts (1.0 in pro, 3.0-6.0 in exp) in random directions, then recombines.  
- **Modes**: Subtle fringe in pro; wild split in exp.  

### vhs_degrade  
- **Purpose**: Emulates VHS noise and scanlines.  
- **Technique**: Adds gaussian noise (15 in pro, 30-60 in exp) and random sine wave lines (0.2-0.5 scale, 100-200 offset), blended at 0.4 opacity.  
- **Modes**: Light static in pro; heavy VHS chaos in exp.  

### color_fade  
- **Purpose**: Ages the image with a faded look.  
- **Technique**: Reduces intensity (0.3 in pro, 0.5-0.8 in exp) with random offset (30-50), cast to uchar.  
- **Modes**: Soft fade in pro; pronounced aging in exp.  

### soft_focus  
- **Purpose**: Creates a dreamy blur effect.  
- **Technique**: Applies gaussian blur (3 in pro, 5-8 in exp), blends with random factor (0.4 in pro, 0.6-0.8 in exp).  
- **Modes**: Gentle haze in pro; ethereal blur in exp.  

### double_exposure  
- **Purpose**: Blends two images for a surreal effect.  
- **Technique**: Overlays the same image (or a second if provided) with random opacity (0.3-0.6), cast to uchar.  
- **Modes**: Subtle blend in pro; stronger mix in exp.  

### polaroid_frame  
- **Purpose**: Adds a Polaroid-style border.  
- **Technique**: Creates a frame with random border size (20 in pro, 30-50 in exp) and colors, composites the image inside.  
- **Modes**: Clean frame in pro; weathered look in exp.  

### tape_degradation  
- **Purpose**: Simulates warped, noisy tape.  
- **Technique**: Adds noise (15 in pro, 30-50 in exp), resizes with random warp (0.2 in pro, 0.4-0.8 in exp), and rotates slightly, blended at 0.4 opacity.  
- **Modes**: Mild warp in pro; extreme distortion in exp.  

### frame_distortion  
- **Purpose**: Twists the image frame like a projector glitch.  
- **Technique**: Rotates by random angle (-5 to 5 in pro, -15 to 15 in exp), crops to original size.  
- **Modes**: Slight tilt in pro; dramatic twist in exp.  

### super8_flicker  
- **Purpose**: Adds Super 8 film flicker.  
- **Technique**: Draws random rectangles (4 in pro, 8-12 in exp) with varying sizes and intensities, blurs, and blends at 0.3 opacity.  
- **Modes**: Subtle flicker in pro; intense flashes in exp.  

### cinemascope_bars  
- **Purpose**: Adds cinematic letterbox bars.  
- **Technique**: Calculates bar height with random factor (0.4 in pro, 0.6-0.9 in exp), draws black bars, composites image between.  
- **Modes**: Thin bars in pro; thick, variable bars in exp.  

### halftone_print  
- **Purpose**: Creates a dotted print effect.  
- **Technique**: Ranks greyscale image with random size (8 in pro, 12-18 in exp), blends at 0.3 opacity.  
- **Modes**: Fine dots in pro; coarse pattern in exp.  

### film_scratches  
- **Purpose**: Adds reel scratches.  
- **Technique**: Draws random vertical lines (4 in pro, 8-12 in exp) with variable width and intensity, blurs, blends at 0.3 opacity with random factor (0.4-0.9).  
- **Modes**: Light scratches in pro; heavy marks in exp.  

### film_stock_emulation  
- **Purpose**: Emulates classic film tones.  
- **Technique**: Adjusts RGB with subtle shifts (e.g., Kodachrome: +0.1 red, -0.05 green), boosts slightly (0.1 in pro, 0.2-0.3 in exp).  
- **Modes**: Authentic tones in pro; richer hues in exp.  

### sprocket_holes  
- **Purpose**: Adds 35mm film perforations.  
- **Technique**: Draws random-sized holes (8 in pro, 12-20 in exp) along edges with variable spacing, composites image inside.  
- **Modes**: Neat holes in pro; irregular perforations in exp.  

### lens_flare  
- **Purpose**: Adds dramatic light streaks.  
- **Technique**: Draws random lines (3 in pro, 5-8 in exp) with full brightness (255, 200-255, 180-255), blurs, blends at 0.3 opacity.  
- **Modes**: Soft streaks in pro; bold flares in exp.  

### glitch  
- **Purpose**: Creates digital breakup effects.  
- **Technique**: Shifts RGB bands randomly (10 in pro, 20-40 in exp), adds noise with random sigma (10-20), blends at 0.4 opacity.  
- **Modes**: Mild glitch in pro; extreme breakup in exp.

---

## JSON Recipe Usage

For precise control, create a JSON file (e.g., recipe.json):  
   - { "film_grain": 0.5, "sepia": 0.3, "film_scratches": 0.4 }  
Enter the filename when prompted to apply fixed effects instead of random ones.

---

## Troubleshooting

### Library Errors  
   - Verify libvips with "doas pkg_info libvips".  
   - Set "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" if libvips isn’t found.

### Effects Too Strong  
   - Switch to professional mode or reduce "effects per variation" (e.g., 2 instead of 3).  
   - Use a JSON recipe for fixed, lighter intensities.

### Variations Too Similar  
   - The script now guarantees randomness—rerun to see fresh results.  
   - Increase "variations" or "effects per variation" for more diversity.

---

## Notes

- **Randomness**: Effects, intensities, and parameters are fully randomized per variant.  
- **Performance**: libvips ensures fast processing, even with complex stacks.  
- **Customization**: Add new effects to the EFFECTS hash or tweak EXPERIMENTAL_EFFECTS for your style.

```rb
#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Postpro.rb - Analog and Cinematic Post-Processing
# Version: 13.3.14
# Updated: 2025-04-04
# Requires: ruby-vips (>= 2.1.0), tty-prompt
# Compatible with: libvips 8.14.3 via ruby-vips
# Description: Transforms digital images with true random variations.

require "vips"
require "logger"
require "tty-prompt"
require "json"
require "time"

File.write("postpro.log", "") if File.exist?("postpro.log")
$logger = Logger.new("postpro.log", "daily", level: Logger::DEBUG)
$logger = Logger.new(STDERR) if $logger.nil?
$cli_logger = Logger.new(STDOUT, level: Logger::INFO)
PROMPT = TTY::Prompt.new

EFFECTS = {
  "film_grain" => :film_grain,
  "light_leaks" => :light_leaks,
  "lens_distortion" => :lens_distortion,
  "sepia" => :sepia,
  "bleach_bypass" => :bleach_bypass,
  "lomo" => :lomo,
  "golden_hour_glow" => :golden_hour_glow,
  "cross_process" => :cross_process,
  "bloom_effect" => :bloom_effect,
  "film_halation" => :film_halation,
  "teal_and_orange" => :teal_and_orange,
  "day_for_night" => :day_for_night,
  "anamorphic_simulation" => :anamorphic_simulation,
  "chromatic_aberration" => :chromatic_aberration,
  "vhs_degrade" => :vhs_degrade,
  "color_fade" => :color_fade,
  "soft_focus" => :soft_focus,
  "double_exposure" => :double_exposure,
  "polaroid_frame" => :polaroid_frame,
  "tape_degradation" => :tape_degradation,
  "frame_distortion" => :frame_distortion,
  "super8_flicker" => :super8_flicker,
  "cinemascope_bars" => :cinemascope_bars,
  "halftone_print" => :halftone_print,
  "film_scratches" => :film_scratches,
  "film_stock_emulation" => :film_stock_emulation,
  "sprocket_holes" => :sprocket_holes,
  "lens_flare" => :lens_flare,
  "glitch" => :glitch
}.freeze

EXPERIMENTAL_EFFECTS = %w[vhs_degrade tape_degradation super8_flicker lens_flare glitch chromatic_aberration].freeze

PARAM_RANGES = {
  "double_exposure" => { "blend_mode" => %w[over add multiply] },
  "polaroid_frame" => { "border_style" => %w[classic worn] },
  "cinemascope_bars" => { "aspect_ratio" => %w[2.35:1 1.85:1] },
  "film_stock_emulation" => { "stock_type" => %w[kodak_portra fuji_velvia] }
}.freeze

def random_effects(count, mode)
  available = EFFECTS.keys.shuffle # Shuffle for true randomness
  if mode == "experimental"
    bold = (available & EXPERIMENTAL_EFFECTS).sample(count / 2 + rand(2)) # Bias towards experimental effects
    subtle = (available - EXPERIMENTAL_EFFECTS).sample(count - bold.size)
    (bold + subtle).shuffle.take(count).map(&:to_sym)
  else
    available.take(count).map(&:to_sym)
  end
end

def random_intensity(mode)
  if mode == "experimental"
    rand(0.5..2.0) # Wider range for crazy effects
  else
    rand(0.2..0.8) # Subtle range for professional
  end
end

def load_image(file)
  $logger.debug "Loading #{file}"
  raise "File '#{file}' not found or unreadable" unless File.exist?(file) && File.readable?(file)
  image = Vips::Image.new_from_file(file)
  $logger.debug "Loaded #{file}: #{image.width}x#{image.height}, #{image.bands} bands, avg: #{image.avg}"
  if image.bands < 3
    $logger.debug "Converting to sRGB (#{image.bands} bands to 3)"
    image = image.colourspace("srgb")
  elsif image.bands > 3
    $logger.debug "Image has alpha channel (#{image.bands} bands), reducing to 3 bands"
    image = image.extract_band(0, n: 3)
  end
  image
rescue StandardError => e
  $logger.error "Failed to load #{file}: #{e.message}\n#{e.backtrace.join("\n")}"
  nil
end

def apply_effects(image, effects_array, mode)
  $logger.debug "Starting effects on image with avg: #{image.avg}, bands: #{image.bands}"
  original_avg = image.avg
  effects_array.each do |effect|
    next unless EFFECTS.key?(effect)
    intensity = random_intensity(mode)
    $cli_logger.info "Applying #{effect} (intensity: #{intensity.round(2)})"
    $logger.debug "Pre-#{effect} avg: #{image.avg}, bands: #{image.bands}"
    image = send(effect, image, intensity, mode)
    image = image.extract_band(0, n: 3) if image.bands > 3
    change = (image.avg - original_avg).round(2)
    $logger.debug "Post-#{effect} avg: #{image.avg}, bands: #{image.bands}, change from original: #{change}"
    $logger.warn "#{effect} had no impact (change: #{change})" if change.abs < 1.0
  end
  final_change = (image.avg - original_avg).round(2)
  $logger.debug "Effects complete, final avg: #{image.avg}, total change: #{final_change}"
  image
rescue StandardError => e
  $logger.error "Failed to apply effects: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def apply_effects_from_recipe(image, recipe, mode)
  $logger.debug "Starting recipe on image with avg: #{image.avg}, bands: #{image.bands}"
  original_avg = image.avg
  recipe.each do |effect, params|
    next unless EFFECTS.key?(effect.to_s)
    intensity = params.is_a?(Hash) ? params["intensity"].to_f : params.to_f
    $cli_logger.info "Applying recipe #{effect} (intensity: #{intensity.round(2)})"
    $logger.debug "Pre-#{effect} avg: #{image.avg}, bands: #{image.bands}"
    image = if effect == "double_exposure"
              blend_mode = params.is_a?(Hash) ? params["blend_mode"] || "over" : "over"
              send(:double_exposure, image, nil, blend_mode, mode)
            elsif effect == "polaroid_frame"
              border_style = params.is_a?(Hash) ? params["border_style"] || "classic" : "classic"
              send(:polaroid_frame, image, intensity, border_style, mode)
            elsif effect == "cinemascope_bars"
              aspect_ratio = params.is_a?(Hash) ? params["aspect_ratio"] || "2.35:1" : "2.35:1"
              send(:cinemascope_bars, image, intensity, aspect_ratio, mode)
            elsif effect == "film_stock_emulation"
              stock_type = params.is_a?(Hash) ? params["stock_type"] || "kodak_portra" : "kodak_portra"
              send(:film_stock_emulation, image, intensity, stock_type, mode)
            else
              send(effect, image, intensity, mode)
            end
    image = image.extract_band(0, n: 3) if image.bands > 3
    change = (image.avg - original_avg).round(2)
    $logger.debug "Post-#{effect} avg: #{image.avg}, bands: #{image.bands}, change from original: #{change}"
    $logger.warn "#{effect} had no impact (change: #{change})" if change.abs < 1.0
  end
  final_change = (image.avg - original_avg).round(2)
  $logger.debug "Recipe complete, final avg: #{image.avg}, total change: #{final_change}"
  image
rescue StandardError => e
  $logger.error "Failed to apply recipe: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def film_grain(image, intensity, mode)
  sigma = mode == "professional" ? 20 * intensity : 40 * intensity # Reduced from 60/100
  $logger.debug "Generating noise with sigma: #{sigma}"
  noise = Vips::Image.gaussnoise(image.width, image.height, sigma: sigma)
  noise = noise * (rand(0.5..1.0)) # Randomize grain density
  $logger.debug "Noise generated: bands=#{noise.bands}, avg=#{noise.avg}"
  noise = noise.bandjoin([noise] * (image.bands - 1)) if noise.bands < image.bands
  result = (image + noise * 0.2).cast("uchar") # Reduced from 0.5
  $logger.debug "film_grain applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in film_grain: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def light_leaks(image, intensity, mode)
  overlay = Vips::Image.black(image.width, image.height, bands: image.bands)
  count = mode == "professional" ? 2 : rand(4..8)
  $logger.debug "Adding #{count} light leaks"
  count.times do
    x, y = rand(image.width), rand(image.height)
    radius = image.width / (rand(1..3))
    color = mode == "professional" ? [200 * intensity, 100 * intensity, 50 * intensity] : [255 * intensity, rand(150..200) * intensity, rand(50..100) * intensity]
    overlay = overlay.draw_circle(color, x, y, radius, fill: true)
  end
  overlay = overlay.gaussblur(mode == "professional" ? 10 * intensity : rand(15..25) * intensity)
  result = (image + overlay * 0.3).cast("uchar")
  $logger.debug "light_leaks applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in light_leaks: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def lens_distortion(image, intensity, mode)
  identity = Vips::Image.identity.uint8(image.width, image.height)
  factor = mode == "professional" ? 0.1 * intensity : rand(0.3..0.7) * intensity
  $logger.debug "Applying lens distortion with factor: #{factor}"
  dx = identity.linear(factor, -intensity * rand(2..5)).cast("float")
  dy = identity.linear(factor, -intensity * rand(2..5)).cast("float")
  result = image.mapim(dx.bandjoin(dy))
  $logger.debug "lens_distortion applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in lens_distortion: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def sepia(image, intensity, mode)
  shift = mode == "professional" ? 0.1 * intensity : 0.2 * intensity
  $logger.debug "Applying sepia with shift: #{shift}"
  matrix = [0.9 + shift, 0.7 - shift / 2, 0.2, 0.3, 0.8 + shift / 2, 0.15 - shift / 2, 0.25 - shift / 2, 0.6, 0.1 + shift]
  result = image.recomb(matrix).cast("uchar")
  $logger.debug "sepia applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in sepia: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def bleach_bypass(image, intensity, mode)
  gray = image.colourspace("grey16").cast("uchar")
  blend_factor = mode == "professional" ? 0.4 : rand(0.6..0.9)
  $logger.debug "Applying bleach bypass with blend_factor: #{blend_factor}"
  blend = image * (1 - blend_factor * intensity) + gray * (blend_factor * intensity)
  result = blend.linear([1.2], [15 * intensity]).cast("uchar")
  $logger.debug "bleach_bypass applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in bleach_bypass: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def lomo(image, intensity, mode)
  sat_factor = mode == "professional" ? 0.2 * intensity : rand(0.4..0.7) * intensity
  $logger.debug "Applying lomo with sat_factor: #{sat_factor}"
  saturated = image.linear([1.0 + sat_factor], [0])
  vignette = Vips::Image.black(image.width, image.height, bands: image.bands)
  vignette = vignette.draw_circle([rand(150..200) * intensity] * image.bands, image.width / 2, image.height / 2, image.width / rand(1..2), fill: true)
  result = (saturated + vignette * 0.3).cast("uchar")
  $logger.debug "lomo applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in lomo: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def golden_hour_glow(image, intensity, mode)
  overlay = Vips::Image.black(image.width, image.height, bands: image.bands)
  color = mode == "professional" ? [200 * intensity, 160 * intensity, 120 * intensity] : [255 * intensity, rand(180..220) * intensity, rand(150..180) * intensity]
  $logger.debug "Applying golden hour glow with color: #{color}"
  overlay = overlay.draw_circle(color, image.width / 2, image.height / 2, image.width / rand(1..3), fill: true)
  overlay = overlay.gaussblur(mode == "professional" ? 8 * intensity : rand(10..20) * intensity)
  result = (image + overlay * 0.3).cast("uchar")
  $logger.debug "golden_hour_glow applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in golden_hour_glow: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def cross_process(image, intensity, mode)
  r, g, b = image.bandsplit
  r_shift = mode == "professional" ? 0.15 * intensity : rand(0.3..0.6) * intensity
  g_shift = mode == "professional" ? 0.1 * intensity : rand(0.2..0.4) * intensity
  b_shift = mode == "professional" ? 0.2 * intensity : rand(0.4..0.7) * intensity
  $logger.debug "Applying cross process with shifts: r=#{r_shift}, g=#{g_shift}, b=#{b_shift}"
  r = r.linear([1 + r_shift], [rand(10..20) * intensity])
  g = g.linear([1 - g_shift], [0])
  b = b.linear([1 + b_shift], [-rand(5..10) * intensity])
  result = Vips::Image.bandjoin([r, g, b]).cast("uchar")
  $logger.debug "cross_process applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in cross_process: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def bloom_effect(image, intensity, mode)
  boost = mode == "professional" ? 1.5 * intensity : rand(2.0..3.0) * intensity
  $logger.debug "Applying bloom with boost: #{boost}"
  bright = image.linear([boost], [0]).gaussblur(rand(8..15) * intensity)
  result = (image + bright * 0.3).cast("uchar")
  $logger.debug "bloom_effect applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in bloom_effect: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def film_halation(image, intensity, mode)
  highlights = image > rand(180..220)
  blur = mode == "professional" ? 6 * intensity : rand(10..15) * intensity
  $logger.debug "Applying film halation with blur: #{blur}"
  halo = highlights.gaussblur(blur).linear(0.1 * intensity, 0)
  halo = halo.bandjoin([halo] * (image.bands - 1)) if halo.bands < image.bands
  result = (image + halo * 0.3).cast("uchar")
  $logger.debug "film_halation applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in film_halation: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def teal_and_orange(image, intensity, mode)
  r, g, b = image.bandsplit
  r_shift = mode == "professional" ? 0.15 * intensity : rand(0.3..0.5) * intensity
  g_shift = mode == "professional" ? 0.1 * intensity : rand(0.15..0.3) * intensity
  b_shift = mode == "professional" ? 0.2 * intensity : rand(0.4..0.6) * intensity
  $logger.debug "Applying teal and orange with shifts: r=#{r_shift}, g=#{g_shift}, b=#{b_shift}"
  r = r.linear([1 + r_shift], [rand(5..10) * intensity])
  g = g.linear([1 - g_shift], [0])
  b = b.linear([1 + b_shift], [0])
  result = Vips::Image.bandjoin([r, g, b]).cast("uchar")
  $logger.debug "teal_and_orange applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in teal_and_orange: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def day_for_night(image, intensity, mode)
  dark_factor = mode == "professional" ? 0.3 * intensity : rand(0.5..0.8) * intensity
  $logger.debug "Applying day for night with dark_factor: #{dark_factor}"
  darkened = image.linear([1 - dark_factor], [-rand(15..25) * intensity])
  r, g, b = darkened.bandsplit
  b_boost = mode == "professional" ? 0.1 * intensity : rand(0.2..0.4) * intensity
  b = b.linear([1 + b_boost], [rand(8..12) * intensity])
  result = Vips::Image.bandjoin([r, g, b]).cast("uchar")
  $logger.debug "day_for_night applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in day_for_night: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def anamorphic_simulation(image, intensity, mode)
  stretch = mode == "professional" ? 0.1 * intensity : rand(0.2..0.4) * intensity
  $logger.debug "Applying anamorphic simulation with stretch: #{stretch}"
  result = image.resize(1.0 + stretch, vscale: rand(0.9..1.1))
  $logger.debug "anamorphic_simulation applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in anamorphic_simulation: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def chromatic_aberration(image, intensity, mode)
  shift = mode == "professional" ? 1.0 * intensity : rand(3.0..6.0) * intensity
  $logger.debug "Applying chromatic aberration with shift: #{shift}"
  r, g, b = image.bandsplit
  r = r.roll(shift, rand(-shift..shift))
  b = b.roll(-shift, rand(-shift..shift))
  result = Vips::Image.bandjoin([r, g, b]).cast("uchar")
  $logger.debug "chromatic_aberration applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in chromatic_aberration: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def vhs_degrade(image, intensity, mode)
  sigma = mode == "professional" ? 15 * intensity : rand(30..60) * intensity
  $logger.debug "Applying VHS degrade with sigma: #{sigma}"
  noise = Vips::Image.gaussnoise(image.width, image.height, sigma: sigma)
  lines = Vips::Image.sines(image.width, image.height).linear(rand(0.2..0.5) * intensity, rand(100..200))
  noise = noise.bandjoin([noise] * (image.bands - 1)) if noise.bands < image.bands
  image_plus_lines = (image + lines * 0.4).cast("uchar")
  result = (image_plus_lines + noise * 0.4).cast("uchar")
  $logger.debug "vhs_degrade applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in vhs_degrade: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def color_fade(image, intensity, mode)
  fade_factor = mode == "professional" ? 0.3 * intensity : rand(0.5..0.8) * intensity
  $logger.debug "Applying color fade with fade_factor: #{fade_factor}"
  result = image.linear([1 - fade_factor], [rand(30..50) * intensity]).cast("uchar")
  $logger.debug "color_fade applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in color_fade: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def soft_focus(image, intensity, mode)
  blur = mode == "professional" ? 3 * intensity : rand(5..8) * intensity
  $logger.debug "Applying soft focus with blur: #{blur}"
  blurred = image.gaussblur(blur)
  blend_factor = mode == "professional" ? 0.4 : rand(0.6..0.8)
  result = (image * (1 - blend_factor) + blurred * blend_factor).cast("uchar")
  $logger.debug "soft_focus applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in soft_focus: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def double_exposure(image, second_image_path, blend_mode = "over", mode = "professional")
  $logger.debug "double_exposure: Blend mode #{blend_mode}"
  second = second_image_path ? load_image(second_image_path) : image
  unless second&.bands == image.bands
    $logger.warn "double_exposure: Band mismatch or no second image (image: #{image.bands}, second: #{second&.bands})"
    return image
  end
  second = second.resize(image.width.to_f / second.width) if second.width != image.width
  result = (image + second * rand(0.3..0.6)).cast("uchar")
  $logger.debug "double_exposure applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in double_exposure: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def polaroid_frame(image, intensity, border_style = "classic", mode = "professional")
  border = mode == "professional" ? 20 * intensity : rand(30..50) * intensity
  $logger.debug "Applying polaroid frame with border: #{border}, style: #{border_style}"
  frame_width = image.width + border * 2
  frame_height = image.height + border * 2 + border * 0.5
  frame = Vips::Image.black(frame_width, frame_height, bands: image.bands)
  frame_color = mode == "professional" ? [245, 245, 225] : [rand(240..255), rand(240..255), rand(220..240)]
  frame = frame.draw_rect(frame_color, 0, 0, frame_width, frame_height, fill: true)
  worn_color = mode == "professional" ? [210, 190, 170] : [rand(180..210), rand(160..190), rand(140..170)]
  frame = frame.draw_rect(worn_color, border / 2, border / 2, frame_width - border, frame_height - border * 1.5, fill: true) if border_style == "worn"
  result = frame.composite2(image, "over", x: border, y: border)
  $logger.debug "polaroid_frame applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in polaroid_frame: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def tape_degradation(image, intensity, mode)
  sigma = mode == "professional" ? 15 * intensity : rand(30..50) * intensity
  $logger.debug "Applying tape degradation with sigma: #{sigma}"
  noise = Vips::Image.gaussnoise(image.width, image.height, sigma: sigma)
  warp_factor = mode == "professional" ? 0.2 * intensity : rand(0.4..0.8) * intensity
  warped = image.resize(1 + warp_factor, vscale: rand(0.9..1.1)).rotate(rand(-5..5) * intensity)
  noise = noise.bandjoin([noise] * (image.bands - 1)) if noise.bands < image.bands
  intermediate = (image + noise * 0.3).cast("uchar")
  result = (intermediate + warped * 0.4).cast("uchar")
  $logger.debug "tape_degradation applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in tape_degradation: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def frame_distortion(image, intensity, mode)
  angle_range = mode == "professional" ? (-5..5) : (-15..15)
  angle = rand(angle_range) * intensity
  $logger.debug "Applying frame distortion with angle: #{angle}"
  rotated = image.rotate(angle)
  offset = (image.width * Math.sin(angle.abs * Math::PI / 180) / 2).to_i
  result = rotated.crop(offset, offset, image.width, image.height)
  $logger.debug "frame_distortion applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in frame_distortion: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def super8_flicker(image, intensity, mode)
  flicker = Vips::Image.black(image.width, image.height, bands: image.bands)
  count = mode == "professional" ? 4 : rand(8..12)
  $logger.debug "Applying super8 flicker with #{count} flickers"
  count.times do
    flicker = flicker.draw_rect([rand(80..120) * intensity] * image.bands, rand(image.width), rand(image.height), rand(25..60), rand(25..60), fill: true)
  end
  flicker = flicker.gaussblur(mode == "professional" ? 4 * intensity : rand(6..10) * intensity)
  result = (image + flicker * 0.3).cast("uchar")
  $logger.debug "super8_flicker applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in super8_flicker: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def cinemascope_bars(image, intensity, aspect_ratio = "2.35:1", mode = "professional")
  ratio = aspect_ratio == "2.35:1" ? 2.35 : 1.85
  height_factor = mode == "professional" ? 0.4 : rand(0.6..0.9)
  $logger.debug "Applying cinemascope bars with ratio: #{ratio}, height_factor: #{height_factor}"
  bar_height = ((image.height - (image.width / ratio)) / 2).to_i * intensity * height_factor
  bars = Vips::Image.black(image.width, image.height, bands: image.bands)
  bars = bars.draw_rect([0] * image.bands, 0, 0, image.width, bar_height, fill: true)
  bars = bars.draw_rect([0] * image.bands, 0, image.height - bar_height, image.width, bar_height, fill: true)
  result = bars.composite2(image, "over")
  $logger.debug "cinemascope_bars applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in cinemascope_bars: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def halftone_print(image, intensity, mode)
  grey = image.colourspace("grey16").cast("uchar")
  rank_size = mode == "professional" ? 8 : rand(12..18)
  $logger.debug "Applying halftone print with rank_size: #{rank_size}"
  dots = grey.rank(rank_size, rank_size, rand(3..5)).linear([1.2 * intensity], [0])
  result = (image + dots * 0.3).cast("uchar")
  $logger.debug "halftone_print applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in halftone_print: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def film_scratches(image, intensity, mode)
  scratches = Vips::Image.black(image.width, image.height, bands: image.bands)
  count = mode == "professional" ? 4 : rand(8..12)
  $logger.debug "Applying #{count} film scratches"
  count.times do
    x = rand(image.width)
    width = rand(2..5) * intensity
    scratches = scratches.draw_rect([rand(200..255) * intensity] * image.bands, x, 0, width, image.height, fill: true)
  end
  scratches = scratches.gaussblur(mode == "professional" ? 2 * intensity : rand(3..5) * intensity)
  opacity = mode == "professional" ? 0.4 : rand(0.6..0.9)
  $logger.debug "Applying scratches with opacity: #{opacity}"
  result = (image + scratches * opacity * 0.3).cast("uchar") # Reduced overall impact
  $logger.debug "film_scratches applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in film_scratches: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def film_stock_emulation(image, intensity, stock_type = "kodak_portra", mode = "professional")
  r, g, b = image.bandsplit
  if stock_type == "kodak_portra"
    $logger.debug "Applying Kodak Portra emulation"
    r = r.linear([1 + 0.1 * intensity], [10 * intensity])
    g = g.linear([1 - 0.05 * intensity], [0])
    b = b.linear([1 - 0.07 * intensity], [-5 * intensity])
  else # fuji_velvia
    $logger.debug "Applying Fuji Velvia emulation"
    r = r.linear([1 + 0.15 * intensity], [15 * intensity])
    g = g.linear([1 + 0.1 * intensity], [0])
    b = b.linear([1 + 0.05 * intensity], [0])
  end
  boost = mode == "professional" ? 0.1 : rand(0.2..0.3)
  result = Vips::Image.bandjoin([r, g, b]).linear([1 + boost], [0]).cast("uchar")
  $logger.debug "film_stock_emulation applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in film_stock_emulation: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def sprocket_holes(image, intensity, mode)
  hole_size = mode == "professional" ? 8 * intensity : rand(12..20) * intensity
  spacing = mode == "professional" ? 25 * intensity : rand(20..30) * intensity
  $logger.debug "Applying sprocket holes with size: #{hole_size}, spacing: #{spacing}"
  frame = Vips::Image.black(image.width + hole_size * 2, image.height, bands: image.bands)
  frame = frame.draw_rect([rand(220..240)] * image.bands, 0, 0, frame.width, frame.height, fill: true)
  (0...(image.height / spacing).to_i).each do |i|
    y = i * spacing + hole_size / 2
    frame = frame.draw_rect([0] * image.bands, 0, y, hole_size, hole_size, fill: true)
    frame = frame.draw_rect([0] * image.bands, frame.width - hole_size, y, hole_size, hole_size, fill: true)
  end
  result = frame.composite2(image, "over", x: hole_size, y: 0)
  $logger.debug "sprocket_holes applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in sprocket_holes: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def lens_flare(image, intensity, mode)
  flare = Vips::Image.black(image.width, image.height, bands: image.bands)
  count = mode == "professional" ? 3 : rand(5..8)
  $logger.debug "Applying #{count} lens flares"
  count.times do
    x, y = rand(image.width), rand(image.height)
    length = mode == "professional" ? 80 * intensity : rand(150..300) * intensity
    flare = flare.draw_line([255, rand(200..255), rand(180..255)], x, y, x + length, y)
  end
  flare = flare.gaussblur(mode == "professional" ? 5 * intensity : rand(8..12) * intensity)
  result = (image + flare * 0.3).cast("uchar")
  $logger.debug "lens_flare applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in lens_flare: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def glitch(image, intensity, mode)
  r, g, b = image.bandsplit
  shift = mode == "professional" ? 10 * intensity : rand(20..40) * intensity
  $logger.debug "Applying glitch with shift: #{shift}"
  r = r.roll(rand(-shift..shift), rand(-shift..shift))
  g = g.roll(rand(-shift..shift), rand(-shift..shift))
  b = b.roll(rand(-shift..shift), rand(-shift..shift))
  noise = Vips::Image.gaussnoise(image.width, image.height, sigma: rand(10..20) * intensity)
  noise = noise.bandjoin([noise] * (image.bands - 1)) if noise.bands < image.bands
  result = Vips::Image.bandjoin([r, g, b]) + (noise * 0.4).cast("uchar")
  $logger.debug "glitch applied, avg: #{result.avg}, bands: #{result.bands}"
  result
rescue StandardError => e
  $logger.error "Failed in glitch: #{e.message}\n#{e.backtrace.join("\n")}"
  raise
end

def process_file(file, variations, recipe, apply_random, effect_count, mode)
  $logger.debug "Processing #{file}: #{variations} variations, #{effect_count} effects, #{mode} mode"
  image = load_image(file)
  return 0 unless image
  original_avg = image.avg

  processed_count = 0
  variations.times do |i|
    $logger.debug "Variation #{i + 1} for #{file}"
    processed_image = if recipe
                        apply_effects_from_recipe(image, recipe, mode)
                      elsif apply_random
                        variation_effects = random_effects(effect_count, mode)
                        $logger.debug "Selected effects for variation #{i + 1}: #{variation_effects}"
                        apply_effects(image, variation_effects, mode)
                      else
                        $cli_logger.warn "No effects selected, skipping variation #{i + 1}"
                        next
                      end

    unless processed_image
      $logger.error "Variation #{i + 1} failed: nil image"
      next
    end

    # Polish steps with randomization
    if mode == "professional"
      polish_intensity = random_intensity(mode)
      processed_image = film_stock_emulation(processed_image, polish_intensity, "kodak_portra", mode)
      $logger.debug "Post-stock emulation avg: #{processed_image.avg}"
    end
    polish_intensity = random_intensity(mode)
    processed_image = film_grain(processed_image, polish_intensity, mode)
    $logger.debug "Post-grain avg: #{processed_image.avg}"
    polish_intensity = random_intensity(mode)
    processed_image = film_scratches(processed_image, polish_intensity, mode)
    $logger.debug "Post-scratches avg: #{processed_image.avg}"
    processed_image = processed_image.extract_band(0, n: 3) if processed_image.bands > 3

    final_avg = processed_image.avg
    change = (final_avg - original_avg).round(2)
    if change.abs < 10.0
      $logger.warn "Variation #{i + 1} has minimal change (#{change}), effects may be subtle"
    end

    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    output_file = file.sub(File.extname(file), "_processed_v#{i + 1}_#{timestamp}#{File.extname(file)}")
    begin
      processed_image.write_to_file(output_file)
      $cli_logger.info "Saved variation #{i + 1} as #{output_file}, avg: #{final_avg}, change: #{change}"
      processed_count += 1
    rescue StandardError => e
      $logger.error "Failed to save #{output_file}: #{e.message}\n#{e.backtrace.join("\n")}"
    end
  end
  processed_count
rescue StandardError => e
  $logger.error "Processing #{file} failed: #{e.message}\n#{e.backtrace.join("\n")}"
  processed_count || 0
end

def get_input
  $logger.debug "Starting input collection"
  $cli_logger.info "Postpro.rb v13.3.14 - Transform your images with analog and cinematic flair!"
  mode = PROMPT.yes?("Professional mode? (Yes for subtle, No for bold experimental)", default: true) ? "professional" : "experimental"
  apply_random = PROMPT.yes?("Apply random effects? (No for custom recipe)", default: true)
  recipe_file = PROMPT.ask("Custom JSON recipe file (or press Enter for none):", default: "").strip
  patterns = PROMPT.ask("File patterns (default: **/*.{jpg,jpeg,png,webp}):", default: "**/*.{jpg,jpeg,png,webp}").strip
  file_patterns = patterns.split(",").map(&:strip)
  variations = PROMPT.ask("Number of variations per image (1-5):", convert: :int, default: 3) { |q| q.in("1-5") }
  effect_count = apply_random ? PROMPT.ask("Effects per variation (1-5):", convert: :int, default: 3) { |q| q.in("1-5") } : 0

  recipe = nil
  unless recipe_file.empty?
    if File.exist?(recipe_file)
      recipe = JSON.parse(File.read(recipe_file))
      $cli_logger.info "Loaded recipe from '#{recipe_file}'"
    else
      $cli_logger.warn "Recipe file '#{recipe_file}' not found, proceeding without recipe"
    end
  end

  [file_patterns, variations, recipe, apply_random, effect_count, mode]
rescue StandardError => e
  $logger.error "Input failed: #{e.message}\n#{e.backtrace.join("\n")}"
  nil
end

def main
  $logger.debug "Starting Postpro.rb v13.3.14"
  inputs = get_input
  unless inputs
    $cli_logger.error "Failed to gather input, exiting."
    return
  end
  file_patterns, variations, recipe, apply_random, effect_count, mode = inputs

  files = file_patterns.flat_map { |p| Dir.glob(p.strip) }.uniq.reject { |f| f.match?(/processed_v\d+_\d+/) }
  if files.empty?
    $cli_logger.error "No files matched: #{file_patterns.join(', ')}"
    $logger.error "No valid files found"
    return
  end

  $cli_logger.info "Processing #{files.size} file#{files.size == 1 ? '' : 's'}..."
  total_variations = successful_files = 0
  retries = {}

  files.each do |file|
    retries[file] ||= 0
    begin
      variation_count = process_file(file, variations, recipe, apply_random, effect_count, mode)
      total_variations += variation_count
      successful_files += 1 if variation_count > 0
    rescue StandardError => e
      $logger.error "Error processing #{file}: #{e.message}\n#{e.backtrace.join("\n")}"
      if retries[file] < 2
        retries[file] += 1
        $cli_logger.warn "Retrying #{file} (attempt #{retries[file] + 1}/2)"
        retry
      else
        $cli_logger.error "Failed #{file} after 2 retries: #{e.message}"
      end
    end
  end

  $cli_logger.info "Completed: #{successful_files} file#{successful_files == 1 ? '' : 's'} processed, #{total_variations} variation#{total_variations == 1 ? '' : 's'} created"
  $logger.info "Execution completed: #{successful_files} files, #{total_variations} variations"
rescue StandardError => e
  $logger.error "Unexpected failure: #{e.message}\n#{e.backtrace.join("\n")}"
end

main if $0 == __FILE__
```
