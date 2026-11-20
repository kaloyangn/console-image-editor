# Console Image Tool — Web edition

A browser mirror of the Console Image Tool workflow. This edition processes
user-selected files locally and creates downloadable results. It does not run
the Windows application or require ImageMagick, an account, installation, a
backend, a CDN or a paid service.

## Open and use

Download or clone the repository, then open `web/public/index.html` in a current
desktop browser. GitHub's file view displays source rather than running the app.
No build or dependency
installation is required. A static HTTP preview is also possible; the app has no
hard-coded hostname, route fallback or absolute asset paths.

1. Drop your image files onto the page, or press **Enter** to choose files.
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
in the visible operation transcript. Repeated runs append summaries rather than
replacing earlier operations. The persistent Repeat last button works on the
current selection, including a newly uploaded batch. Earlier summaries remain
after removing an input; download/preview links apply to its latest live output.
Clear in the selection menu
releases all loaded images/results. Every run starts from the original files.

The app does not save images,
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
canvas limits. SVG text is limited to 8 MiB and 10,000 elements.
These are app limits to bound common memory use, not browser performance
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

## Files and hosting

[`public/index.html`](public/index.html) is the complete browser application,
including its CSS, JavaScript, image processing and ZIP export. There is no build
command, dependency installation or backend. Edit this file directly; no separate
release or deployment copy is needed. The Windows files in the repository root
are independent and are not needed for web hosting.

Any static host that serves HTML and allows the page's inline CSS and JavaScript
can serve this app. Your hosting provider does not need to be your internet
service provider. Server-side ImageMagick, PHP, Node.js and databases are not
required.

### Deploy to a static host

1. Choose a static host or an existing website's public document root. Use the
   provider's upload interface, deployment workflow, or SFTP/FTPS client as
   supported by that host. Keep credentials outside the repository.
2. Upload **only `web/public/index.html`**. For a subdirectory installation,
   create a folder such as `console-image-editor` in the document root and put
   `index.html` inside it. Do not upload the enclosing `web/` or `public/` folder
   unless you intend those names to appear in the URL.
3. Open the resulting address, for example
   `https://example.com/console-image-editor/index.html`. The shorter
   `/console-image-editor/` address also works if the host serves `index.html`
   as its directory index. The app uses no hard-coded hostname or asset paths.
4. Check that the host serves the file as HTML and that its security policy
   permits the inline scripts and styles. No route rewrites are required.
5. Test the checklist below in your target browsers. For updates, retain the
   previous HTML for rollback, replace the deployed file and refresh the browser
   cache. Leave unrelated site files untouched.

Use HTTPS for a public deployment. Image processing stays in the browser, but
secure delivery still matters because a modified page could access selected
images. Hosting configuration and deployment are separate from downloading this
repository; no particular provider or live deployment is implied.

## Verification and known gaps

Development checks have covered keyboard menus, custom backgrounds, inversion,
SVG/SVGZ rendering and rejection of unsafe SVG, first-frame GIF handling, output
encoders, PNG compression, action chains, cancellation and per-file failures.
Local Chromium checks also exercised automatic single-image and batch-ZIP
downloads and a narrow viewport. These checks used synthetic fixtures.

Later sample/recipe removal received syntax and element-reference checks.
Repeat/history changes passed 16 state/DOM checks with a mocked canvas; those
changes have not received a full visual browser check or real image-encoding
regression run. Desktop tests do not establish browser-edition correctness.

Native file-picker selection and Explorer drag/drop, Safari/Firefox, physical
mobile devices, large real-world batches, complex SVG fidelity and hosted
deployment remain unverified. Synthetic drop events are not native drag/drop
validation.

### Check your deployment

- Open both the directory URL (if supported) and explicit `index.html`; reload
  and navigate directly to the page.
- Check layout, keyboard navigation, generated previews and browser console
  errors. Confirm the app makes no remote resource or upload requests.
- Select and drop representative images. Check transparency, trim, backgrounds,
  padding, inversion, chains, repeat on a new batch and clear error messages.
- Compare real SVG/SVGZ logos visually, especially fonts and filters; check
  unsupported-content rejection.
- Download PNG/JPEG/WebP/ICO and a batch ZIP; open them independently. Check
  dimensions, naming, first-frame behavior and PNG output below 5,242,880 bytes.
- Check operation history across uploads and repeated actions. Reload should
  clear the session; images and settings are not persisted by the app.
- Test a small viewport, selection, cancellation and a modest batch on the
  browsers and devices you intend to support.

Implementation references: [Canvas encoding](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/toBlob),
[image bitmap decoding](https://developer.mozilla.org/en-US/docs/Web/API/Window/createImageBitmap),
[gzip decompression](https://developer.mozilla.org/en-US/docs/Web/API/DecompressionStream).
