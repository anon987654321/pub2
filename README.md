# AKMD Audio Collection

## Overview

This collection contains 35 audio tracks processed with a consistent lofi analog mastering chain, optimized for web playback and audio-reactive visualizations at 128kbps MP3.

## File Naming Convention

All tracks follow the pattern: `akmd-artist_name-track_title.mp3`

**Artists included:**
- Chase Swayze (17 tracks from "The Living Daylights Vol 1")
- Johann & Collaborators (Angelo Reira, Haisam, Jan Hakim, Mike T)
- J Dilla
- Whyppedcream

## Mastering Process

All tracks have been processed through an identical mastering chain to ensure consistent sonic texture, loudness levels, and lofi analog character across the entire collection.

### Signal Chain

**1. Frequency Shaping (Lofi Tape Character)**
- 60Hz highpass filter (removes sub-bass rumble)
- 11.5kHz lowpass filter (vintage tape-style rolloff)
- Creates warm, bandwidth-limited analog feel

**2. Three-Band EQ (Console Warmth)**
- +3dB @ 80Hz (Q=1.5) - Bass warmth and body
- +2dB @ 200Hz (Q=1.0) - Lower midrange fullness
- -3dB @ 8kHz (Q=2.0) - Tamed high frequencies, reduced harshness

**3. Compression (Analog Glue)**
- Threshold: -20dB
- Ratio: 3:1 (gentle compression)
- Attack: 10ms (preserves transients)
- Release: 80ms (natural envelope)
- Makeup gain: +4dB
- Purpose: Adds cohesion, controls dynamics, increases perceived loudness

**4. Soft Saturation (Tape/Tube Character)**
- Type: Hyperbolic tangent (tanh) clipping
- Effect: Adds subtle harmonic distortion for analog warmth
- Prevents harsh digital clipping
- Introduces even-order harmonics characteristic of tape/tube circuits

**5. Volume Boost & Final Limiting**
- Volume increase: 1.5x (pre-limiting)
- Limiter threshold: -0.92dB (broadcast-safe)
- Limiter attack: 3ms (fast)
- Limiter release: 50ms (smooth)
- Prevents digital clipping while maximizing loudness

### Technical Specifications

**Output Format:**
- Codec: MP3 (libmp3lame)
- Bitrate: 128kbps CBR (constant bitrate)
- Sample rate: 44.1kHz
- Channels: Stereo
- Purpose: Web-optimized for streaming and audio-reactive applications

**Processing Resolution:**
- Internal processing: 32-bit float
- Dither: Automatic (built into encoder)

### Implementation

The mastering chain was implemented using FFmpeg with the following filter graph:

```bash
highpass=f=60,lowpass=f=11500,
equalizer=f=80:t=q:w=1.5:g=3,
equalizer=f=200:t=q:w=1:g=2,
equalizer=f=8000:t=q:w=2:g=-3,
acompressor=threshold=-20dB:ratio=3:attack=10:release=80:makeup=4,
asoftclip=type=tanh,
volume=1.5,
alimiter=limit=0.92:attack=3:release=50
```

### Sonic Characteristics

The resulting audio has the following qualities:

**Frequency Response:**
- Warm, rolled-off high end (no harsh digital brightness)
- Enhanced low-mids and bass (body and warmth)
- Bandwidth-limited like vintage tape or vinyl

**Dynamics:**
- Consistent loudness across all tracks
- Gentle compression maintains punch while increasing density
- Natural transient response (drums still hit)

**Texture:**
- Subtle analog saturation throughout
- Cohesive "glue" from compression
- Lofi aesthetic without being lo-fi quality
- Broadcast-safe levels for all playback systems

### Inspiration & Philosophy

This mastering approach is inspired by:
- **Vintage Hardware:** SP-1200/MPC3000 lofi aesthetic
- **Broadcast Consoles:** SSL/Neve-style processing chains
- **Analog Tape:** Frequency rolloff and saturation characteristics
- **Dilla Production:** Warm, compressed, slightly saturated sound
- **Modern Lofi:** Contemporary lofi hip-hop mastering techniques

The goal was to create a cohesive collection where all tracks blend seamlessly together, with consistent loudness and sonic texture suitable for continuous playback in audio-reactive visual environments.

### Comparison to dilla.rb

While this collection uses FFmpeg for streamlined batch processing, a more sophisticated vintage emulation tool (`dilla.rb`) is available in `/g/pub/multimedia/` that implements:
- Mathematical recreation of J Dilla's "drunk drummer" timing
- SP-1200 (26kHz, 12-bit) and MPC3000 hardware emulation
- Golden ratio swing (54.2%) with voice-specific microtiming
- Jiles-Atherton hysteresis modeling for tape saturation
- Analog console crosstalk and transformer modeling

This collection prioritizes consistency and web optimization over maximum vintage authenticity.

## Usage

These tracks are optimized for:
- Web audio players
- Audio-reactive visualizations (see `/g/pub/index.html`)
- Streaming playback
- Continuous mix/playlist scenarios
- Lofi hip-hop aesthetic applications

All tracks maintain consistent loudness (-14 LUFS target approximate) and can be played back-to-back without level jumps.

## Processing Date

All tracks processed: October 1, 2025

## Tools Used

- **FFmpeg 8.0** (audio processing)
- **yt-dlp** (source download)
- **ffprobe** (metadata analysis)

---

*Processed with care for the lofi analog aesthetic.*
