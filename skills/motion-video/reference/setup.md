# Setup checklist (once per project)

The project brings and owns its dependencies; this skill brings none. Tick every item before the
first video in a project. Each one exists because it broke the Claude showreel.

A complete, verified implementation of everything below lives in the AirsoftOne repo, if it's on
the machine: `~/work/perso/airsoftone/packages/video/` (`remotion.config.ts`, `src/showreel/`,
`scripts/showreel/`, `src/showreel/DEV.md`). Read it as a worked example, don't depend on it.

## 1. Dependencies (installed by the project)

- [ ] **Remotion.** `remotion` and `@remotion/cli`, with every `remotion` and `@remotion/*`
      package pinned to ONE exact version: a mismatch throws. Add others as needed: `@remotion/three`
      for three.js, and `@remotion/layout-utils`, `@remotion/paths`, `@remotion/noise`,
      `@remotion/media-utils`, `@remotion/transitions`, `@remotion/shapes`.
- [ ] **3D, particles, shaders.**
  - `three` and `@react-three/fiber` (v9 for React 19); `@react-three/drei` and
    `@react-three/postprocessing` + `postprocessing` if used.
  - Exactly one copy of three: check with `pnpm why three` or `npm ls three`.
- [ ] **zod.** If Remotion prints a zod "Version mismatch" (another package in the workspace ships
      a different zod), pin `zod` in the video package. That's Remotion's own documented fix.
- [ ] **Tools.** ffmpeg on the PATH, for contact sheets, intermediates and the final transcodes.
      Python 3 for the soundtrack, in a local venv (numpy, scipy, soundfile, pyloudnorm,
      matplotlib).
- [ ] **Fonts** as local woff2 files. The Google Fonts CSS2 API returns woff2 only with a desktop
      Chrome User-Agent. Take the latin subset, and remember that `→` and `≠` are not in it.
- [ ] **All installs done before fanning out to parallel agents.**

A set that worked together (September 2026): remotion 4.0.529, three 0.186.1, @react-three/fiber
9.8.1, drei 10.7.8, @react-three/postprocessing 3.1.2, postprocessing 6.39.5, react 19.3.0,
zod 4.5.4.

## 2. `remotion.config.ts`

```ts
import { Config } from '@remotion/cli/config';

Config.setChromiumOpenGlRenderer('angle'); // the default can't create a WebGL context; angle = the GPU
Config.setVideoImageFormat('png'); // lossless frames, flat colours stay exact
Config.setColorSpace('bt709'); // tag the output colours
Config.setCachingEnabled(false); // parallel agents bundling different entries wipe a shared cache
```

- [ ] **TypeScript 7.** If the project or a parent monorepo pins TypeScript 7, also pass
      `tsconfigRaw` to Remotion's esbuild-loader through `Config.overrideWebpackConfig`, or every
      render crashes at ~24% bundling. Adding TS 5 to the video package does not help. The AirsoftOne
      config has the exact override.

## 3. Layout (one folder per video)

- `lib/theme.ts` + `lib/cues.json`: the contract. Canvas, tempo, palette, fonts, curves, section
  map, handoff geometry, cues.
- `scenes/<Section>.tsx` + `scenes/<section>/`: one file and one helpers folder per section.
- `fx/`: HUD, grain, HUD tone track.
- `entries/<section>.tsx`: one isolated entry per section, which registers a root with only that
  section's composition.
- `index.ts` + `Root.tsx` + `<Video>.tsx`: the assembly.
- [ ] `tsconfig.json` has `resolveJsonModule` (for the `cues.json` import).

## 4. Helpers to write, or copy from a previous video

- [ ] **Fonts loader.** Register each `FontFace` with its real descriptors (weight range, stretch
      range, style) inside `delayRender`/`continueRender`, idempotent, so no frame ever renders with a
      fallback font.
- [ ] **`<Composer>`.** A drop-in replacement for `@react-three/postprocessing`'s `EffectComposer`,
      which renders an empty first frame in every render tab and makes stills always empty. The
      replacement renders synchronously in R3F's frame loop (AirsoftOne: `src/showreel/lib/three.tsx`,
      51 lines).
- [ ] **Contact sheet.**
  - It renders only the frames it keeps: pass the `--frames` list, at scale 0.5.
  - It tiles them with ffmpeg, 6 columns, each frame numbered in a strip under its tile.
  - Remotion refuses a PNG-sequence output path containing a dot (a home folder like
    `/Users/first.last` has one), so pass paths relative to the package.
- [ ] **Pixel sampling** (a 1×1 ffmpeg crop to RGB hex), to check handoffs and exact colours.
- [ ] **Per-entry typecheck**, so a half-written file of another agent doesn't fail yours.
- [ ] **Pipeline scripts**: render-footage (visually lossless H.264 4:4:4 at CRF 6 for anything
      `OffthreadVideo` reads back), hud-tones (per-corner luminance → tone track), render-final (a
      ProRes 422 HQ master, then an H.264 transcoded from it, with the original 24-bit WAV muxed into
      the master).

## 5. Smoke tests (before any scene)

- [ ] **Fonts.** A still with the display font at two widths and two weights, plus the serif italic
      and the mono. Read it: the axes must really change the glyphs, with no faux bold and no fallback.
- [ ] **three.js.** A still of a lit mesh with soft shadows and bloom through `<Composer>`. On a
      `flat` canvas, a `MeshBasicMaterial` must come out at the exact CSS hex (check with pixel
      sampling).
- [ ] **Motion blur.** A fast-moving box, blurred as expected.
- [ ] **Speed.** Time a 60-frame 1080p render, so you know the budget per frame (target under
      ~1.5 s for the heaviest scene).
