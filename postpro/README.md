# Postpro.rb – Analog and Cinematic Post-Processing

**Version:** 12.9.0  
**Last Modified:** 2025-02-03T00:00:00Z  
**Author:** PubHealthcare  

---

Postpro.rb is an **interactive CLI** tool that applies analog and cinematic effects to images using [libvips](https://libvips.github.io/libvips/) via [ruby-vips](https://github.com/libvips/ruby-vips). It allows **recursive batch processing** of entire folders,
layering multiple transformations—such as film grain,
blur,
halation,
VHS-style degrade,
and more—for a fully customized look.

---

## Key Features

1. **Analog & Retro**  
   - **Film Grain & Vignetting**: Classic film texture  
   - **VHS Degrade & Light Leaks**: 80s/90s analog feel  

2. **Cinematic Looks**  
   - **Bloom & Halation**: Dreamy highlight glows  
   - **Teal-and-Orange & Day-for-Night**: Hollywood-grade color grading  
   - **Anamorphic Simulation**: Widescreen lens flares  

3. **Layered Processing**  
   - Combine multiple effects (grain, hue shifts, color fade, etc.) in one pass  
   - Fine-tune each effect’s intensity  

4. **Interactive CLI**  
   - Choose random or custom JSON recipes  
   - Specify file patterns (e.g., `**/*.jpg`) to batch-process recursively  

5. **High Speed & Low Memory**  
   - Built on libvips, known for its efficient, fast performance  

---

## Example Interactive Flow

```bash
$ ruby postpro.rb
Apply a random combination of effects? (Y/n): y
Enter file patterns (default: **/*.jpg, **/*.jpeg, **/*.png, **/*.webp): images/**/*.jpg
How many variations per image? (default: 3): 4

Starting image processing...
Processing file: images/pic1.jpg
Applied effect: film_grain (intensity: 1.2)
Applied effect: teal_and_orange (intensity: 1.0)
Applied effect: bloom_effect (intensity: 1.5)
Saved variation 1 as images/pic1_processed_v1_20250203151145.jpg
Saved variation 2 as images/pic1_processed_v2_20250203151145.jpg
Saved variation 3 as images/pic1_processed_v3_20250203151145.jpg
Saved variation 4 as images/pic1_processed_v4_20250203151145.jpg
Processing completed.
```

- **Random Effects** or **Load a JSON recipe**  
- **Recursive** matching: `images/**/*.{jpg,png}`  
- **Multiple Variations**: e.g., 4 unique outputs per file  

---

## Installation

1. **Install libvips**  
   - **OpenBSD**: `pkg_add vips`  
   - **Ubuntu/Debian**: `apt-get install libvips`  
   - **macOS**: `brew install vips`

2. **Install Ruby Gems**  
   ```bash
   gem install --user-install ruby-vips tty-prompt
   ```

### OpenBSD Tips

On **OpenBSD**, ensure **libvips** is recognized:
```sh
doas pkg_add -U vips
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```
Confirm that **ruby-vips** is installed and the `.so` is in your `LD_LIBRARY_PATH`.

---

## JSON Recipe Usage

Create a JSON file (e.g., `myrecipe.json`):

```json
{
  "film_grain": 1.0,
  "day_for_night": 0.8,
  "bloom_effect": 1.2
}
```

Then, when prompted, enter the filename to **apply that exact recipe**.

---

## Advanced Notes

- **Multiple Effects**: Stack **grain, hue shift, vhs_degrade, halation** in one pass for unique combos.  
- **Performance**: libvips processes large images quickly with minimal memory.  
- **Cinematic Controls**: Adjust intensities to preserve skin tones or push stylized extremes.
