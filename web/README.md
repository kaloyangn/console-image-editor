# Console Image Tool — Web edition

A browser mirror of the Console Image Tool workflow. This edition processes
user-selected files locally and creates downloadable results. It does not run
the Windows application or require ImageMagick, an account, installation, a
backend, a CDN or a paid service.

## Open and use

Open `public/index.html` in a current desktop browser. No build or dependency
installation is required. A static HTTP preview is also possible; the app has no
hard-coded hostname, route fallback or absolute asset paths.

1. Drop image files onto the page, or press **Enter** to choose files. **D** on
   the drop screen loads a synthetic sample without opening a file picker.
2. Use **Up/Down arrows** to highlight an action and **Enter** to activate it.
   Menus wrap; Home/End choose first/last. Clicking a row also activates it.
3. After processing, a single result downloads as an image; a batch downloads
   as one ZIP. If the browser blocks a download, use the result's Download link.
4. Results show before/after dimensions, size, elapsed time and errors. Press
   **Enter** to choose more files, **A** to choose another action for the current
   originals, or **R** to repeat the last action. Preview is an optional link.

The black background, monospace text, cyan banner/highlight and sequential menus
follow the desktop console. There is no separate editor dashboard or mandatory
preview/confirmation step before processing.

| Action-menu shortcut | Behavior |
| --- | --- |
| C | Compress PNG strictly below 5 MiB |
| W / B | White / black background + 20 px per side |
| H | Custom hex color, then padding prompts; Enter accepts default padding 20 |
| I | Invert RGB while preserving alpha |
| F | Format menu: PNG, JPEG, WebP where available, ICO; JPEG/WebP quality prompt |
| A | Build a chain of up to eight actions |
| R | Repeat the last action/chain on the current originals |
| O | Automatic downloads, always ZIP, or manual result links |
| M | Explain fixed metadata stripping and browser limitations |
| S | Select/remove loaded images: Space toggles, Delete removes, G continues |

In the chain menu, action letters append steps in order. Backspace undoes the
last step. Enter activates the highlighted row; after adding a step, the **Run
action chain** row is selected so Enter runs it. Arrow navigation can also select
an action to append. Custom color/format prompts return to the chain when done.
Put compression last if the final output must remain below 5 MiB.

Esc backs out of a menu/prompt. During processing it stops after the current
file. At the drop prompt it pauses the session instead of closing a browser tab.
A new drop selects the new batch; prior loaded images/results remain available
through selection/results menus until removed. Clear in the selection menu
releases all loaded images/results. Every run starts from the original files.

Recipe export/import transfers settings only using versioned JSON; existing
version 1 recipes from the previous UI remain compatible. Import opens the chain
for review rather than running automatically. The app does not save images,
results or settings to localStorage/IndexedDB. Reload closes the session.

## Supported behavior

- Inputs: browser-decoded PNG, JPEG, WebP and GIF; a restricted static SVG subset.
  Animated GIF/WebP are snapshotted with `createImageBitmap` using their default
  image/first frame. APNG is rejected because its separate default image need
  not be frame zero. No animation, layer or page editing.
- SVG rasterization: minimum longest edge 2048 pixels, preserve aspect ratio and
  larger explicit dimensions, support viewBox-only geometry and physical units.
  Raster inputs are not automatically enlarged.
- SVGZ / `.svg.gz`: built-in `DecompressionStream('gzip')`, if available, with an
  8 MiB expanded-text limit. Otherwise use uncompressed SVG. No fallback library
  or secure-context dependency is required for other inputs.
- Background: one optional `#`, three/six hex digits; padding 0..4096 whole pixels
  per side. White/black shortcuts reset padding to 20. Trim transparent outer
  edges only, then fill transparency and padding. An entirely transparent input
  becomes a one-pixel background plus padding.
- RGB inversion preserves alpha. Transparent pixels' hidden RGB values may be
  normalized by browser canvas premultiplication.
- Outputs: PNG, JPEG and WebP when the browser encoder supports the requested
  MIME type (checked at startup and on each encoding), plus a single PNG-backed
  ICO entry fitted within 256 × 256. JPEG flattens transparency onto white.
- Compression: encode PNG, then reduce RGB precision if needed, then reduce
  dimensions until encoded output is strictly below 5,242,880 bytes. Alpha is
  retained. Color/dimensions may change and output may exceed original input size.
  Put compression last; a later operation can increase output size again.
- Source EXIF, GPS and text fields are not copied into the new canvas output.
  Browser-generated color/resolution information can remain. Copyright-only
  retention is unavailable. This is not a print/HDR/color-profile fidelity tool.
- Originals are read, never written. Results receive distinct session filenames;
  the browser controls destination folders and existing filesystem collisions.

## Limits and deliberate differences from desktop

The browser edition does not include ImageMagick's broad codec set: no TIFF,
PSD, PDF, HEIC, AVIF or specialist desktop conversions, and no arbitrary local
folder scan/output-folder selection. ICO input is not included. It does not
trace raster images to editable vectors. Browser text/fonts and complex SVG
filters can differ from the desktop renderer.

Uploaded SVG is parsed, checked and rendered in an isolated image context; it
is never inserted into the app DOM. Unsupported elements (including script,
animation, image, foreignObject and style sheets), external references, event
handlers, classes and unsupported CSS constructs cause a clear rejection rather
than a silent partial conversion. Use static self-contained paths, shapes,
internal gradient references and inline presentation styles. Embedded raster
images and external/custom fonts are not supported.

Working limits: 40 files, 32 MiB each, 200 MiB aggregate input, 8192 pixels per
edge, 16 million pixels per canvas, 100 MiB aggregate results. Padding must fit
canvas limits. SVG text is limited to 8 MiB and 10,000 elements; recipe JSON to
16 KiB. These are app limits to bound common memory use, not browser performance
guarantees. Decoder allocation can occur before dimensions are known for some
formats. Mobile devices may hit memory limits sooner; use smaller batches.

ZIP export uses uncompressed ZIP entries (images are already encoded). Required
CRC-32 values and UTF-8 filenames are included. It contains ready results only;
per-file failures are shown in the batch results. Preview images are limited to
1000 pixels for display; downloads use the actual processed dimensions.

Image contents stay in the page session; the app has no upload, analytics or
remote resource requests. Browser/OS download and temporary-file handling remain
outside the app's control. An HTTP-delivered page can be tampered with in transit;
local processing does not make HTTP suitable for sensitive images.

## Project organization

```text
Image_Tool.bat       existing Windows application
ImageMagick/         existing Windows engine and notices
release/             existing desktop portable ZIP
web/
  AGENTS.md          browser-edition guidance
  README.md          this guide (not a deployment file)
  public/
    index.html       complete browser application; upload this one file
```

Git was initialized on `main` with the desktop baseline in a separate initial
commit. Both editions live together, separated by directory. Create temporary
feature branches for future work if useful; a permanent branch split would make
it harder to view and share both editions together. Check `git remote -v` for the
current GitHub state; local version control does not imply a published remote.

## Build and deploy

Build command: **none**. Edit the inline CSS/classic JavaScript in
`public/index.html`. No `type=module`, runtime imports, external scripts, external
SVG assets, WASM or server config is used. Do not introduce a normal framework
module build without adapting it to the shared hosting guide.

There is one web app file: **`web/public/index.html`**. It contains the CSS,
classic JavaScript, processing engine and ZIP-result creation code. No other
dependencies or web release/deployment copies are needed. The user explicitly
requested removal of the redundant web `deploy/` and `release/` folders.
The desktop portable ZIP remains independent.

## Manual Vivacom deployment


1. Open **`web/public/`** locally. Its `index.html` is the complete web app.
2. In FileZilla, use your established Vivacom connection. Keep FTP credentials
   out of app files and logs. The supplied audit reports unencrypted FTP.
3. Open your website's document root in FileZilla's remote pane. Confirm the
   actual document root in your connection; no server path is assumed.
4. Create/open a **`console-image-editor`** folder under that remote root, then
   drag **`web/public/index.html`** into it. Do not upload the enclosing `web` or
   `public` folder. The resulting remote file must be
   `console-image-editor/index.html` relative to your web root. For an update,
   keep the previous HTML locally for rollback and replace only this app's file;
   leave your homepage and other apps alone. No Windows executables, documentation,
   Git files, private images or settings belong in the deployment.
5. Visit **`mysite.com/console-image-editor/index.html`**, substituting your actual
   hostname and its available HTTP/HTTPS scheme. No installation, build or server
   configuration is needed. `/console-image-editor/` can also use the host's
   directory index behavior.
6. Follow the actual-host checklist below. For an update, upload the replacement
   HTML and hard-refresh. Do not rely on configurable cache/rewrite/MIME headers.
   Roll back by restoring the previous `index.html` if needed.

No upload, account change, hosting migration or live probe is part of this local
build. HTTPS availability and actual-host browser behavior remain unverified.

## Verification

Temporary automated image checks and interactive browser checks are used during
development; fixtures and harnesses are removed before handoff. Results from
desktop tests do not establish correctness of this edition.

Observed on 18 November 2026 in the local in-app Chromium browser after the console
redesign: **24/24 automated checks passed**. They cover menu wrapping/Home/End,
file-drop transition, arrow/Enter activation, repeat, custom background prompts
and validation, Esc/back behavior, chains/undo/eight-step limits, format/quality
prompts, output modes, metadata explanation, selection/removal, compatible recipe
imports, pause/resume, pixel-level backgrounds/inversion, SVG/SVGZ rendering and
unsafe-content rejection, animated GIF first frame, output encoders, large PNG
compression, stop/restart and isolated per-file failures. The processing engine
was retained from the previously tested edition (30 checks before this redesign).

The real keyboard UI was also exercised: D loads a sample, Down highlights White,
and Enter processes it and automatically downloads a PNG. A two-image run
automatically downloaded one ZIP. Production-page console errors were absent in
the checked flows. The downloaded PNG was independently inspected with the
bundled ImageMagick engine; the ZIP contained two PNGs with distinct names and
the expected dimensions. The console menu was observed at desktop and 390-pixel
width with no horizontal overflow at the smaller size. Tests use synthetic
fixtures rather than production artwork.

Actual browser file-picker selection, native drag/drop from Explorer, recipe
file chooser/export UI, Safari/Firefox, physical mobile devices, large real-world
batches, complex SVG fidelity and actual Vivacom deployment remain unverified.
The temporary harness tested synthetic drop events and recipe import data.

Actual-host acceptance checklist (pending until observed on Vivacom):

- Directory URL, explicit `index.html`, direct navigation and reload work.
- Page layout, inline code and generated previews load without console errors or
  remote/CDN requests; test target Opera/Chrome/Edge/Firefox/Safari as relevant.
- Select/drop representative images. Verify transparency, trim, backgrounds,
  padding, inversion, chains, original preservation and actionable failures.
- Verify SVG/SVGZ on the actual browser, including rejection cases; compare real
  logos visually, especially fonts and filters.
- Download PNG/JPEG/WebP/ICO and a batch ZIP; open them in independent software.
  Check dimensions, naming, first-frame behavior and the strict PNG byte limit.
- Export/import recipes and reject malformed/oversized files. Reload clears image
  state; no browser persistence or backend storage should be expected.
- Test a small viewport, keyboard operation, selection, cancellation and a modest
  batch. Do not fill hosting quota or stress-test the shared service.

Implementation references: [Canvas encoding](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/toBlob),
[image bitmap decoding](https://developer.mozilla.org/en-US/docs/Web/API/Window/createImageBitmap),
[gzip decompression](https://developer.mozilla.org/en-US/docs/Web/API/DecompressionStream).
