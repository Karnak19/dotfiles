# Traps found on the Claude showreel

Each of these cost real time. Most fail silently: the render succeeds and looks wrong.

## Remotion and rendering

- **Determinism.** Remotion renders frames out of order, in parallel browser tabs.
  - Every pixel must be a pure function of the frame number: no state carried across frames, no
    simulation stepping, no `Math.random()`, no `Date.now()`, no R3F clock or delta.
  - Use `random(seed)` from `remotion` and closed-form motion.
  - Particles: compute positions in the vertex shader from per-particle attributes and time.
- **TypeScript 7.** If the project or a parent monorepo pins TypeScript 7 (it ships no JS API),
  Remotion's esbuild-loader crashes at ~24% bundling. Pass `tsconfigRaw` to it from
  `remotion.config.ts` to skip that. Adding TS 5 to the video package does not help.
- **GL renderer.** The default can't create a WebGL context at all. `angle` runs on the Mac's GPU
  (Metal). `swangle` works but is ~13× slower; `egl`, `angle-egl`, `swiftshader` and `vulkan` fail.
- **Bundle cache.** Remotion keeps one cache per project and wipes it whenever a different entry
  is bundled, so parallel agents wipe each other's. Turn it off for parallel work.
- **Isolated entries.** The bundle includes every file imported from the entry, so one agent's
  half-written scene breaks everyone's renders if all use the same entry. Give each section its
  own entry, and typecheck per entry.
- **No installs during a parallel build.** Concurrent installs corrupt `package.json` and the
  lockfile.
- **Footage inside a composition.** `<Freeze frame={k}>` clamps to the host composition's range
  and silently freezes the wrong frame or breaks. Use `trimBefore` inside `<Freeze frame={0}>`.
  For slow motion, blend neighbouring source frames rather than holding each one twice.
- **Intermediate footage for `OffthreadVideo`**: H.264 High 4:4:4 at CRF 6.
  - It measured 49–64 dB PSNR with about 0 colour error.
  - H.264 4:2:0 and ProRes 422 HQ both came back about 2 levels dark.
- **Colour checks.** Check colours on PNG stills; the H.264 drifts 1–3 levels.
- **Master audio.** Remotion writes 16-bit audio into the master. Mux the original 24-bit WAV in
  afterwards, copying the video untouched.
- **AAC** smears a transient after digital silence about 3 ms early. It's inaudible, and the
  master is exact.
- **File size.** Grain eats bitrate: CRF 13 gave 57 Mb/s (108 MB for 15 s). Make a CRF 18–20 web
  version for sharing.

## three.js / React Three Fiber

- **Post-processing.** The stock `EffectComposer` renders an empty first frame in every render
  tab, and stills are always empty. Use `<Composer>` from `src/lib/three.tsx`, or a
  custom render loop that draws synchronously inside R3F's frame loop, as the WORLD scene does.
- **Exact colours.** R3F's default tone mapping shifts colours (bone `#F2EEE6` becomes `#DEDDDB`).
  Put `flat` on any canvas whose colours must match CSS.
- **Bloom** lifts nearby flat colours by up to 16 levels. Only feed it sources brighter than 1, and
  set it to zero on handoff frames.
- **Timing of updates.** An object changed in `useEffect` shows up one frame late. Use JSX props,
  `useLayoutEffect` or `useFrame`, but never read the clock inside `useFrame`.
- **drei helpers** that animate themselves read the R3F clock, so they aren't deterministic.
- **Shadows.** Use `shadows="variance"` or `"percentage"`. Plain `shadows` asks for a shadow type
  that three 0.186 removed.
- **3D text.** drei's `<Text>` can't read woff2, so keep type in the DOM.
- **Raw WebGL canvases** must free their context on unmount, or repeated mounts exhaust Chrome's
  context limit.
- **Cost of tall geometry.** Analytic shadows and AO get expensive with tall geometry. Bake what
  doesn't move and take long steps once rays clear the rooftops. Keep each frame under ~1.5 s.

## 2D, type and motion

- **Fonts** are Google Fonts woff2, latin subset only: `→` and `≠` fall back to a system font.
  - Load them with `delayRender` so no frame renders with a fallback font.
  - Check in a still that the variable axes really change the glyphs.
  - ffmpeg `drawtext` can't read woff2.
- **Goo filters.** SVG "goo" (blur plus alpha threshold) destroys anti-aliasing. Use a
  signed-distance metaball shader, anti-aliased from the field's own screen-space gradient.
  Assuming a flat field turns thin liquid necks into a grey smudge.
- **`CameraMotionBlur`.**
  - It snaps colours inside the wrapper to multiples of the sample count: bone becomes `#F0F0E8`
    at 8 samples.
  - It draws about 0.7 frame ahead, which moves every hit.
  - Wrap only the moving layer and render rest and handoff frames unwrapped, or write a centred
    shutter (the TIMING scene does both).
- **Blur and scale changes.** Blur on a scale change reads as out of focus, so render pop-in
  frames sharp. Schedule abrupt pose changes in the closed half of the shutter so no frame is
  double-exposed.
- **`spring()`** starts at zero velocity, so its peak lands late (around f12 for a snappy
  config). Use a closed-form damped spring when a peak must land on a given frame.
- **Wagon-wheel effect.** A ring of 8 identical dots turning faster than 22.5°/frame looks like it
  spins backwards. Cap the speed.
- **Squash and stretch** always preserve area, and the stretch follows the velocity.
- **Italic centring.** An italic's bounding box lies about its centre. Centre on the ink's area
  centroid.

## Design lessons (the reads that cost rebuild rounds)

- **White hollow tubes** read as tape rolls, and taller ones as paper-towel rolls. Material fixed
  it, not geometry: dark sides, bone tops. Make style frames first.
- **Separate glossy drops** read as candy. Keep liquid connected, with thick viscous bridges,
  organic shapes and reflections of a studio.
- **Scale.** Tiny action in the middle of a big black frame reads timid. A camera push-in or
  pull-back fixes it.
- **Muddy streaks.** A full-screen wash of grey defocused streaks kills contrast. Use fewer, crisp
  streaks with black between them.
- **Static flashes.** A supercut flash on a static moment is dead. Pick a moving moment, or play
  it faster.
- **HUD tones.** A fixed tone table fails on the real picture. Measure luminance per corner per
  frame, and use solid label stickers where the picture is busy.
- **Glitch text.** A HUD flicker with random glyphs reads as a bug. Flicker between real labels
  only.
- **Pre-drop gaps.** A 4-frame gap reads as a hiccup; use a 16th note or more. A visual "lock"
  must land on the audible frame, not inside the silence.

## Soundtrack

- **Engine.** Python venv (numpy, scipy, soundfile, pyloudnorm, matplotlib). Deterministic:
  two renders give the same SHA-256.
- **Timing.** At 48 kHz and 60 fps, frame f is sample f × 800. Hits peak on their cue sample;
  builds (whooshes, risers, reverse swells) end on it.
- **Verify without listening.**
  - A spectrogram and waveform with labelled cue markers.
  - Onset detection against the cues (aim ≤ 5 ms; the reel got ±1.5 ms).
  - Integrated LUFS, true peak, clipping count.
  - Digital zero on the gaps.
  - Then tell the user it was never heard.
