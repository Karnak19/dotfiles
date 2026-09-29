---
name: motion-video
description: Make a studio-grade motion-design video (feature announcement, launch, teaser, recap, reel) for any project, in the house look of the Claude showreel. The project brings its own dependencies; the skill covers a setup checklist for them, a storyboard with a frame-exact cue sheet, style frames before building, parallel scene agents on isolated entries, a synthesized soundtrack, contact-sheet review loops, the final ProRes + H.264 render, and the traps that silently ruin renders. Use when the user asks for a video, an announcement or teaser video, a reel, or motion graphics.
---

# Motion videos

The reference is the Claude showreel (15 s, 1920×1080, 60 fps, 7 sections, custom soundtrack). The
user approved its look on 2026-09-25 and wants videos like it for his products and projects.
If the AirsoftOne repo is on the machine, a render sits at
`~/work/perso/airsoftone/packages/video/out/claude-showreel.mp4` and its full source at
`packages/video/src/showreel/`: a worked example of everything below, not a dependency.

Every pixel is code:

- Remotion (React → frames → video, rendered by headless Chrome on the GPU);
- SVG/HTML and variable fonts for 2D;
- WebGL shaders for liquid shapes;
- three.js with React Three Fiber for 3D and particles;
- a Python DSP engine for the soundtrack;
- ffmpeg for the files.

The one rule: **only the output counts.** Hold it to a top studio reel. Anything that looks like a
template, a slideshow transition, a default easing or a tech demo is a failure, even if it works.

## Setup in a project (once per project)

The project brings and owns its dependencies; this skill brings none. Before the first video in
a project, go through `reference/setup.md`: dependencies, `remotion.config.ts`, layout, the
helpers to write, and the smoke tests to pass before any scene.

## Project defaults (find them before the brief)

- **Language and vocabulary.** On-screen text is in the language of the project's audience. Follow
  the project's AGENTS.md or CLAUDE.md for vocabulary and tone rules.
- **Length and sections.** 10–20 s, 3–5 sections. Seven sections in 15 s is what made the reel
  expensive.
- **Show the real product.** Render the project's real components with its real tokens when it's
  React, or use screen captures from a local or test setup. Never write to production to get a
  capture. No invented UI.
- **Format.** Agree it at the brief, and design the storyboard for it from the start: a 16:9 layout
  does not crop into 9:16. Options are 1920×1080, 1080×1350 (Instagram/Facebook feed) or 1080×1920
  (Reels/Stories).
- **Palette and type.** Default to the reel's look (ink, bone, orange hero, cobalt counter, lime in
  tiny doses; Archivo, Instrument Serif, Geist Mono). If the video should wear the project's
  identity, take its tokens and fonts from its CSS or design docs instead. Confirm with the user at
  the storyboard stage.
- **Publishing.** If the project has a skill for captions and posting, hand the render to it.

## Process

The main agent is the director. It owns the brief, the storyboard, the contract files and the
reviews, and delegates the builds. The briefs that worked are in `reference/briefs.md`.

1. **Brief.** Settle only what changes the plan: the subject and its one message, the format(s),
   the length, the palette.

2. **Concept, storyboard, cue sheet** (director).
   - **One concept that motivates every transition.** The thing on screen becomes the next thing
     (an iris, a shockwave, a camera move, a collapse), never a generic wipe. The reel's concept:
     "from a dot, back to a dot".
   - **Pick a tempo where beats land on whole frames**: 120 BPM at 60 fps is exactly 30 frames a
     beat.
   - **Write the beats of each section in frames**, and the exact state each section hands to the
     next (the handoff).
   - **Write the contract files** `lib/theme.ts` and `lib/cues.json` (layout in
     `reference/setup.md`). They hold canvas, tempo, palette, fonts, curves, section map, handoff geometry and cues.
     Every scene imports from them, and the soundtrack reads the same cue sheet, so picture and
     sound meet on the frames written there.
   - **A hit peaks ON its cue frame**: the contact, the extreme pose or the cut, not the start of
     the move.

3. **Style frames before any motion.** One finished-looking still per section, reviewed at 100%.
   On the reel, white hollow tubes read as tape rolls, then paper-towel rolls, and separate glossy
   drops read as candy. Two ~30-minute rebuild rounds found that late, where a still would have
   caught it in 10 minutes. Fix the look here, not after the build.

4. **Build in parallel.**
   - **One agent per section.** Each owns only its files and renders through its own entry
     (`entries/<section>.tsx`), so another agent's half-written file can't break its bundle.
   - **2D sections start immediately**; they never wait for 3D work.
   - **The sound agent** starts at the same time, from the cue sheet.
   - **Nobody installs packages mid-build**: parallel installs corrupt `package.json` and the
     lockfile. Add missing dependencies before fanning out.

5. **Review loop** (director).
   - Look at each section's contact sheet (every 4–6 frames across the range, every 1–2 frames
     around cues) and its key stills at full size.
   - Check handoffs to the pixel.
   - Send notes with SendMessage to the same agent, so it keeps its context.
   - Aim for 1–2 rounds per section. Judge like an art director: the read of the image, scale in
     frame, contrast, rhythm, edge quality.

6. **Integration**, in this order:
   1. render each section as footage;
   2. build anything that uses footage (supercut, letters as windows);
   3. measure the HUD tones from the real picture;
   4. render the final files.

   The scripts are listed in `reference/setup.md` §4.

7. **Verify, then deliver.**
   - Check the file: ffprobe for size, fps, exact frame count, duration, and audio starting at 0.
   - Read the full contact sheet and a strip around every handoff.
   - Confirm the audio is unshifted, with a known transient on its exact time.
   - Copy the mp4 somewhere the user keeps it (a gitignored `out/`) and `open` it.
   - Make a lighter web version (CRF 18–20) for uploading.
   - You cannot listen: the soundtrack is verified by measurement only, so say so and let the user
     judge it by ear.

## House style (what the user approved)

**Motion language**

- Nothing moves linearly except slow camera drifts. Entrances use expo-out, exits expo-in, moves
  between two rests a snap in-out, and physical things springs.
- Anticipation before every significant move, follow-through after it.
- Overlapping action: letters, tiles and particles never move in unison. Stagger them 1–3 frames
  by a spatial rule.
- Fast moves get motion blur, as from a real shutter: several in-between moments averaged per
  frame.
- Hard cuts only on beats. Silence and stillness are tools: pre-drop gaps are dead still, at least
  a 16th note (8 frames at 120 BPM).
- Contrast of pace: violent snaps next to calm holds.

**Look**

- **Colour.** At most two accents on screen at once, never pure black or white.
- **Type.** Big display type (cap height ≥ 240 px at 1080p), with the variable axes animated. An
  italic serif for names, a mono for technical labels.
- **Texture.** Film grain from seeded tiles, soft-light, with a mean shift under 2 levels, plus a
  5% vignette. Flat colour must never look digitally dead.
- **The designer's process peeking through, sparingly.** Hairline construction lines, measurement
  ticks, and tiny mono labels such as `cubic-bezier(.7,0,.84,0)`.
- **HUD overlay** in the corners: title, timecode, section label, beat squares. Its text tone is
  measured from the real picture per corner, with solid label "stickers" on busy backgrounds.

**Sound**

- Minimal electronic at the tempo of the cue sheet, one designed sound per cue.
- Loudness around −14 LUFS integrated, true peak at most −1 dBTP.
- Kick and bass in mono.
- Digital-zero silences on the gaps.

## Traps

Read `reference/traps.md` before building. Each item there cost real time on the reel. The five
that silently ruin a render:

1. Every pixel must be a pure function of the frame. Remotion renders frames out of order in
   parallel tabs: no state across frames, no `Math.random()`, no clock reads.
2. three.js needs the `angle` GL renderer, and the `<Composer>` fix instead of the stock
   EffectComposer (blank frames).
3. Exact colours need a `flat` canvas, and bloom off near handoffs.
4. The stock `CameraMotionBlur` shifts colours and draws ahead of the frame. Wrap only moving
   layers, or use a centred custom shutter.
5. If the project or a parent monorepo pins TypeScript 7, Remotion's bundler crashes unless
   `remotion.config.ts` passes `tsconfigRaw` (see `reference/setup.md`).

## Cost

The reel took about six hours and hit the org's monthly spend limit once:

- the one-time setup blocked everything for 55 minutes (the setup checklist shortens it);
- each section's first build took about an hour;
- revision rounds took 3 to 40 minutes each;
- integration took about 45 minutes;
- the final render itself took 5 minutes.

To go faster: keep the scope small, make style frames first, never let 2D wait for 3D, and cap
reviews at two rounds per section.
