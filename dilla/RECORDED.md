# Dilla Beat Production Documentation

## Project: FlyLo/Dilla Style Rappable Beat

### Research Summary

**J Dilla Harmonic Characteristics:**
- Uses ii-V-i jazz progressions (tension/release patterns)
- Common modes: C Dorian, D Minor
- Melodic sophistication: constant notes functioning as multiple chord tones
- Simple harmonic framework with complex melodic layers
- Classic example: "So Far To Go" (C Dorian, high chord complexity)

**Flying Lotus Harmonic Characteristics:**
- Unresolved progressions creating "perpetual tension"
- Pattern: V-, IV-, bIIMaj (analyzed from "Never Catch Me")
- Heavily layered textures
- Alice Coltrane influence (lush, textural compositions)
- Wonky/IDM electronic approach

---

## Final Beat: `rappable_beat.mp3`

### Chord Progression (FlyLo-style unresolved)

**Am7 → G7 → Bbmaj7** (8 bars each, looped)

#### Chord 1: Am7 (v- minor 7th)
- A (220 Hz) - Root
- C (261.63 Hz) - Minor 3rd
- E (329.63 Hz) - Perfect 5th
- G (440 Hz) - Minor 7th

#### Chord 2: G7 (IV dominant 7th)
- G (196 Hz) - Root
- B (246.94 Hz) - Major 3rd
- D (293.66 Hz) - Perfect 5th
- F (369.99 Hz) - Minor 7th

#### Chord 3: Bbmaj7 (bII major 7th)
- Bb (233.08 Hz) - Root
- D (293.66 Hz) - Major 3rd
- F (349.23 Hz) - Perfect 5th
- A (440 Hz) - Major 7th

**Harmonic Analysis:**
- Creates perpetual tension (never resolves to tonic)
- Each chord = 8 seconds duration
- Total progression = 24 seconds (looped)
- Creates "floating" FlyLo vibe perfect for rap

---

## Chord Layer Effects Chain

### Input: Synthesized sine wave chords

1. **Vibrato**
   - Frequency: 3.5 Hz
   - Depth: 0.4
   - Purpose: SP-1200 style pitch wobble

2. **Chorus**
   - In gain: 0.65
   - Out gain: 0.85
   - Delay: 50ms
   - Decay: 0.38
   - Speed: 0.22
   - Modulation depth: 2
   - Purpose: Vintage analog width

3. **Echo/Delay**
   - In gain: 0.65
   - Out gain: 0.8
   - Delay: 140ms
   - Decay: 0.32
   - Purpose: Spacious depth

4. **Lo-Fi Filtering**
   - Lowpass: 2800 Hz
   - Highpass: 120 Hz
   - Purpose: Cut harsh frequencies, warm analog sound

5. **Phaser**
   - In gain: 0.68
   - Out gain: 0.82
   - Delay: 2.8ms
   - Decay: 0.38
   - Speed: 0.42 Hz
   - Type: Triangular
   - Purpose: Phase rotation movement

6. **Compand (Compression)**
   - Attack: 0.25s
   - Decay: 1.1s
   - Transfer: -80/-80|-38/-28|-18/-13|0/-7
   - Soft knee: 9
   - Purpose: Glue dynamics together

7. **Volume**
   - Level: 0.32 (32%)
   - Purpose: Leave headroom for drums

8. **Stereo Widening** (Final mix stage)
   - Extrastereo: 1.5x
   - Purpose: Wide stereo field

9. **Tremolo** (Final mix stage)
   - Frequency: 0.18 Hz
   - Depth: 0.22
   - Purpose: Subtle amplitude modulation

---

## Techno Drums

### Drum Elements

#### Kick Drum
- **Synthesis:** Sine wave @ 50 Hz
- **Duration:** 150ms
- **Volume:** 3x boost
- **Pattern:** 4-on-the-floor (every quarter note)
- **Processing:**
  - Highpass filter: 60 Hz
  - Bass boost: +3 dB
  - Treble boost: +2 dB

#### Hi-Hat
- **Synthesis:** White noise
- **Duration:** 50ms
- **Filtering:** Highpass @ 8000 Hz
- **Volume:** 0.8x
- **Pattern:** 16th notes
- **Purpose:** Continuous rhythm texture

#### Snare
- **Synthesis:** Sine wave @ 200 Hz
- **Duration:** 80ms
- **Filtering:** Highpass @ 180 Hz
- **Volume:** 2.5x
- **Pattern:** Backbeat (beats 2 & 4)

### Drum Effects Chain

1. **Fast Compression**
   - Attack: 0.003s (3ms)
   - Decay: 0.08s
   - Transfer: -80/-80|-20/-12|0/-3
   - Soft knee: 2
   - Purpose: Punchy transients

2. **Bass Enhancement**
   - Bass: +3 dB
   - Treble: +2 dB

---

## Master Mix/Summing Chain

### Analog Summing Techniques

1. **Mix Weights**
   - Drums: 1.6x
   - Chords: 1.2x
   - Purpose: Drums-forward rappable mix

2. **Dual Phaser (Analog Phase Rotation)**
   - **Stage 1:**
     - In gain: 0.86
     - Out gain: 0.94
     - Delay: 2.0ms
     - Decay: 0.3
     - Speed: 0.36 Hz
     - Type: Triangular
   - **Stage 2:**
     - In gain: 0.92
     - Out gain: 0.98
     - Delay: 2.5ms
     - Decay: 0.24
     - Speed: 0.3 Hz
     - Type: Sinusoidal
   - Purpose: Stereo movement, phase coherence

3. **Haas Effect (Stereo Width)**
   - Level in: 1.0
   - Level out: 1.0
   - Side gain: 0.38
   - Middle source: Mid
   - Middle phase: False
   - Purpose: Psychoacoustic stereo depth

4. **Glue Compression**
   - Attack: 0.06s
   - Decay: 0.55s
   - Transfer: -80/-80|-34/-24|-20/-12|-10/-7|0/-2
   - Soft knee: 11
   - Purpose: Cohesive mix, analog "glue"

5. **Subsonic Filter**
   - Highpass: 38 Hz
   - Purpose: Remove unwanted rumble

6. **Dynamic Normalization**
   - Frame length: 85ms
   - Gaussian filter: 13 frames
   - Peak value: 0.9
   - Purpose: Final loudness, consistent levels

---

## BPM & Timing

**Estimated BPM:** ~90 BPM (rappable tempo)
- Kick pattern: Quarter notes (4-on-the-floor)
- Hi-hats: 16th notes
- Snare: Beats 2 & 4

**Total Duration:** 24 seconds

---

## Files Generated

1. `flylo_chords.mp3` - Raw chord progression
2. `techno_drums.mp3` - Drum loop (5.32s, looped 4x)
3. `rappable_beat.mp3` - **FINAL MIX**

---

## Production Notes

### Key Characteristics

**FlyLo Influence:**
- Unresolved chord progression (never cadences)
- Creates "perpetual tension" - perfect for rap vocals
- Layered, textural approach

**J Dilla Influence:**
- Vibrato on chords (SP-1200 pitch drift)
- Lo-fi filtering
- Heavy compression for warmth

**Techno Drums:**
- Clean, driving 4/4 pattern
- Minimal but powerful
- Leaves space for vocals

### Recommended Use

- **Genre:** Alternative Hip-Hop, Experimental Rap, Electronic Hip-Hop
- **Vocal Style:** Off-beat flow, syncopated delivery
- **Key:** A minor (relative: C major)
- **Mood:** Floating, tense, forward-moving

---

## Technical Specs

**Sample Rate:** 44100 Hz
**Bit Depth:** 16-bit
**Format:** MP3 (libmp3lame encoder)
**Channels:** Stereo
**Average Bitrate:** ~128 kbps

---

*Generated using ffmpeg synthesizers and analog summing techniques*
*Inspired by J Dilla (Fantastic Vol 1/2) and Flying Lotus (Los Angeles)*
