# Image Studio — Web edition

A separate browser companion to Console Image Tool. This edition processes
user-selected files locally and creates downloadable results. It does not run
the Windows application or require ImageMagick, an account, installation, a
backend, a CDN or a paid service.

## Open and use

Open `public/index.html` in a current desktop browser. No build or dependency
installation is required. A static HTTP preview is also possible; the app has no
hard-coded hostname, route fallback or absolute asset paths.

1. Choose/drop images, or use **Try a sample**.
2. Choose a background, inversion, compression or format conversion.
3. For multiple operations, add up to eight steps to the action chain. Move
   steps up or remove them. When a chain exists, Process uses the chain rather
   than the currently displayed unadded action.
4. Process the checked files. Click a file to preview its original/result.
5. Download individual outputs or one ZIP containing all ready results.

Every run starts from the original files. **Restore last** restores the last
processed recipe; it does not reprocess automatically. Recipe export/import
transfers settings only, using a versioned JSON file. The app does not save
images, results or settings to localStorage/IndexedDB. Reload closes the session.
Stop finishes the current file and leaves remaining files unprocessed.

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
    index.html       complete browser application; source and deployable output
  release/
    Image-Studio-Web.zip   web-only recipient package, ignored by Git
```

Git was initialized on `main` with the desktop baseline in a separate initial
commit. Both editions live together, separated by directory. Create temporary
feature branches for future work if useful; a permanent branch split would make
it harder to view and share both editions together. Check `git remote -v` for the
current GitHub state; local version control does not imply a published remote.

## Build and package

Build command: **none**. Edit the inline CSS/classic JavaScript in
`public/index.html`. No `type=module`, runtime imports, external scripts, external
SVG assets, WASM or server config is used. Do not introduce a normal framework
module build without adapting it to the shared hosting guide.

From the repository root, refresh the separate web package:

```powershell
New-Item -ItemType Directory -Path web\release -Force | Out-Null
Compress-Archive -LiteralPath web\public\index.html -DestinationPath web\release\Image-Studio-Web.zip -Force
```

Only `index.html` belongs in this ZIP. Do not include development files, desktop
executables, private images, Git metadata, credentials or temporary QA pages.
The existing desktop ZIP recipe/package stays independent.

## Manual Vivacom deployment


1. Extract the web ZIP locally, or use `web/public/` directly.
2. In FileZilla, use your established Vivacom connection. Keep FTP credentials
   out of app files and logs. The supplied audit reports unencrypted FTP.
3. Create a dedicated `image-tool` directory under the site's document root.
   Confirm the actual document root in your connection; no server path is assumed.
4. Upload only `index.html` into that directory. Keep any previous version locally
   for rollback; leave your homepage and other applications alone.
5. Visit `/image-tool/` on your actual current hostname.
6. Follow the actual-host checklist below. For an update, upload the replacement
   HTML and hard-refresh. Do not rely on configurable cache/rewrite/MIME headers.
   Roll back by restoring the previous `index.html` if needed.

No upload, account change, hosting migration or live probe is part of this local
build. HTTPS availability and actual-host browser behavior remain unverified.

## Verification

Temporary automated image checks and interactive browser checks are used during
development; fixtures and harnesses are removed before handoff. Results from
desktop tests do not establish correctness of this edition.

Observed on 18 November 2026 in the local in-app Chromium browser: **29/29
integration checks passed**, covering pixel-level backgrounds/alpha/inversion,
validation, original-byte preservation, SVG sizing/gradients/rejections, SVGZ,
APNG rejection, animated GIF first frame, JPEG/WebP round trips, ICO headers and
dimensions, small/large PNG compression, output naming, ZIP structure, batch
chains, reruns and isolated per-file failures. The real UI sample/action-chain
flow and ZIP download passed; the downloaded PNG was independently extracted
with .NET and inspected with the bundled Windows ImageMagick engine. Desktop
and 390-pixel responsive layouts were observed with no horizontal overflow on
the latter, and no production-page console errors were observed in these flows.

The browser-automation file-picker flow stalled, so real picker selection,
drag/drop, recipe file export/import UI and stop/restart remain unverified
interactively. Decoder/batch functions were exercised by the temporary harness.
The suite uses synthetic fixtures, not production artwork. Safari/Firefox,
physical mobile devices, large real-world batches, complex SVG fidelity and
actual Vivacom deployment remain unverified.

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
