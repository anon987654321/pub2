# Radio Bergen Visualizer - Complete Guide

## ✓ FEATURES IMPLEMENTED

### 7 Pixel-Based Visualizers
All visualizers use the same 8-bit flat pixel style as the original tunnel:

1. **Tunnel** - Original warp tunnel (always works as fallback)
2. **Infinity Grid** - Nested square tunnel grid
3. **Cymatic Waves** - Concentric sound wave rings
4. **Fractal Cascade** - Branching fractal trees
5. **Vortex Nest** - Rotating spiral vortexes
6. **Neural Web** - Interconnected pulsing nodes
7. **Cosmic Emanation** - Divine rays from central sun with orbital spheres (Fludd-inspired)

### 6 Color Themes
- Original, Synthwave, Neon, Fire, Ocean, Monochrome

### Beat-Reactive Effects
- **Particle bursts** on bass hits
- **Parallax starfield**

### Mouse & Motion Parallax
- **Desktop**: Move mouse to shift visualizer perspective
- **Mobile**: Tilt device for gyroscope parallax effect
- All visualizers respond with smooth perpendicular motion

### Auto-Switch Per Song
Visualizer automatically changes when the track changes!

## 🎹 KEYBOARD SHORTCUTS

**Existing shortcuts:**
- **M** - Mute/unmute
- **Space/K** - Start or toggle mute
- **←/P** - Previous track
- **→/N** - Next track
- **F/F11** - Toggle fullscreen
- **Escape** - Exit fullscreen
- **0** - Jump to first track
- **I** - Toggle inverted colors

**New shortcuts:**
- **V** - Cycle through visualizers
- **C** - Change color theme
- **B** - Toggle particle effects
- **Shift+S** - Toggle starfield
- **A** - Toggle auto-switch per song
- **↑/↓** - Increase/decrease speed (0.1x - 3.0x)
- **[/]** - Decrease/increase audio intensity (0.2x - 2.0x)
- **X** - Cycle psychedelic effects (Off → Trails → Color Shift → Kaleidoscope)

## 🎵 PLAYING YOUR MP3S

### The Problem
Your 35 MP3 files won't play when opening `index.html` directly as `file://` due to browser security (CORS).

### The Solution
Run a local web server. Choose ONE method:

**Python 3 (recommended):**
```bash
cd G:/pub
python3 server.py
```
Then open: http://localhost:8000/index.html

**Alternative - Python simple server:**
```bash
cd G:/pub
python3 -m http.server 8000
```

**Alternative - Node.js:**
```bash
cd G:/pub
npx http-server -p 8000
```

**Alternative - PHP:**
```bash
cd G:/pub
php -S localhost:8000
```

## 📁 YOUR MP3 FILES

The system detects MP3s from three sources (in order):

1. **mp3/playlist.json** (36 tracks with full metadata) ✓
2. **mp3/playlist.m3u** (not present)
3. **mp3/index.json** (35 tracks auto-detected) ✓

All 35-36 tracks should play once you use HTTP server!

## 🎨 VISUALIZER DETAILS

All new visualizers are:
- **Pixel-perfect** - Same flat 8-bit style as tunnel
- **Safe fallback** - Wrapped in try-catch, original tunnel always works
- **Beat-reactive** - Pulse and expand with bass/audio
- **Theme-compatible** - Work with all 6 color themes
- **Performance-optimized** - Use Uint32Array direct pixel access

## 🔧 TECHNICAL NOTES

- Everything is self-contained in `index.html`
- No external dependencies except `visualizer-enhancements.js`
- MP3 engine has real Web Audio API with FFT analysis
- YouTube fallback still works if no MP3s found
- Original tunnel code completely untouched (safe!)

## 🔧 PERFORMANCE NOTES

All visualizers optimized for **Intel UHD Graphics 600** (low-end integrated graphics):
- VortexNest: Reduced from 15,000 → 1,500 lines/frame (90% reduction)
- FractalCascade: Reduced from 1,280 → 360 lines/frame (72% reduction)
- Applied **geometric clarity principle**: Clear spacing between elements makes patterns recognizable

If you experience stuttering, press V to switch to a different visualizer.

## 🎉 ENJOY!

Open http://localhost:8000/index.html and press Space to start!
The visualizer will auto-change with each new song.
