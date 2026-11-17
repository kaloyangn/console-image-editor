# Console Image Tool

This repository also includes a separate **Console Image Tool web edition** in
[`web/`](web/README.md). Open `web/public/index.html` to try it locally; only that
public folder is intended for website hosting. The Windows console application
and its portable ZIP remain independent. The web edition is not included in the
desktop portable ZIP.

A local Windows console image editor for logos and other images. Batch processing,
backgrounds, conversion, RGB inversion and compression. Originals are preserved;
existing output names receive a numbered suffix instead of being overwritten.

## Run the portable edition

1. Extract **all** of `Console-Image-Tool-Portable.zip` into a writable folder.
2. Double-click `Image_Tool.bat`.
3. Drop images or a folder into the window, or drop them onto the batch file.
4. Choose an action with arrows and Enter, or its displayed letter shortcut.

No ImageMagick installation, Python, PowerShell 7, admin installation, account or
network connection is needed on the recipient's computer. The package uses
Windows PowerShell 5.1, .NET Framework and the Windows classic console host.
The included engine is for Windows x64 (Windows 10/11).

**Managed devices:** portable does not override company application control.
If IT blocks executable files, batch scripts, PowerShell, or runtime C# compilation,
IT must approve the package. `ExecutionPolicy Bypass` applies to this process;
it does not override Group Policy, AppLocker or WDAC. An admin password required
for *installing* software can be avoided; a policy forbidding *running* software
cannot be bypassed by putting it in a ZIP.

Keep `Image_Tool.bat` and the `ImageMagick` folder together. All application code,
including the PowerShell and window-memory helper, is embedded in the batch file.
For source-only use, an installed `magick.exe` on PATH is also supported, with
the bundled portable engine taking precedence when present.

## Small windows and window memory

The batch launcher opens a dedicated classic console, independent of Windows
Terminal tabs. Text wraps at word boundaries, menus adapt when resized and scroll
when too short, and narrow batch results use one file per block.

The last normal window rectangle is sampled every half second and saved per user:

`%LOCALAPPDATA%\ConsoleImageTool\window.json`

Minimized and maximized rectangles are ignored. The saved normal rectangle is
restored on the next launch and clamped to an available monitor's working area,
including after a monitor is disconnected. Delete `window.json` to reset it.
Close after leaving the window in its new position for at least half a second.
Concurrent app windows share this setting; the latest changed window wins.
Launch through the batch file for an independently movable app window.

## Actions

| Shortcut | Action |
| --- | --- |
| C | Compress to PNG strictly below 5 MiB, potentially reducing colors and size |
| W / B | White / black background with 20 pixels of padding per side |
| H | Custom background and padding |
| I | Invert RGB colors while retaining transparency |
| F | Convert format; available choices depend on the selected engine |
| A | Build an ordered action chain (up to 8 steps) |
| R | Repeat the last action or chain within this session |
| O | Save beside originals or choose an existing output folder |
| M | Strip all metadata, or retain only copyright text |

Escape cancels menus and text entry; at the file-drop prompt it closes the app.
Folder scans include immediate files only, not subfolders. Dropping files onto the
batch launcher accepts the first nine arguments; multiple files can also be
dropped into the running editor. Paths containing spaces must be quoted, as with
normal Windows file dragging. The drop prompt accepts a completed paste after a
short idle interval, or Enter. Format and custom background text require Enter.

### Custom backgrounds

Enter a 6-digit color such as `#8FA796` or `8FA796`; 3-digit colors such as `#fff`
also work. The next prompt accepts padding from 0 to 4096 pixels **per side**.
Enter selects 20; zero adds no padding. The color and padding travel with the
action when repeating it or using it in a chain.

Only transparent outer edges are trimmed before padding. White backgrounds in
opaque screenshots are not removed, recolored or automatically cropped. The new
color fills transparency and the added border. A background step produces PNG.
For example, 100 x 50 pixels of opaque content plus 20 pixels per side becomes
140 x 90. Put compression last if the final file must remain below 5 MiB.

### SVG and logo resolution

SVG, SVGZ and `.svg.gz` inputs are rendered with a minimum **longest edge of 2048
pixels**, retaining aspect ratio. A 64 x 16 logo becomes 2048 x 512; a square
becomes 2048 x 2048. Larger SVG canvases retain their dimensions. The renderer
increases decoding density before rasterization, rather than enlarging a tiny
bitmap afterward. ViewBox-only artwork is supported when the SVG renderer can
infer its bounds. SVGZ decompression uses built-in .NET; no gzip installation.

This default gives typical horizontal logos and small subtitles room for clean
display and moderate print use without forcing every logo into a square.
Padding is added afterward; transparent trimming can reduce the visible canvas.
Raster PNG/JPEG logos and screenshots are **not** enlarged automatically, since
upscaling cannot recover missing detail. SVG files that embed low-resolution
bitmap artwork also cannot gain genuine vector detail. ICO output is constrained
to fit 256 x 256, as required by the icon format.

### Other formats and limitations

The editor tries the engine's detected input formats rather than an extension
allowlist, including common raster formats and supported PSD, TIFF, ICO, WebP,
AVIF, JPEG 2000 and other image types. Unreadable files are reported by name.
Conversion menus are generated from the engine's writable format list.
"Other locally supported format" accepts an ImageMagick format identifier.

The portable build includes PNG, JPEG, WebP, GIF, TIFF, ICO, AVIF and JPEG 2000
support. HEIC encoding is absent in this bundled build and is omitted from the
menu. PDF/EPS/AI, some RAW files and other specialist formats may require external
delegates or may be blocked by the engine's policy; the package does not promise
every advertised ImageMagick format works without additional software.

Multi-frame/page files use the **first frame/page only**, including GIF animation,
TIFF pages and layered documents. Conversion to SVG does not trace a bitmap into
editable vector paths. JPEG and BMP flatten transparency onto white. Metadata is
stripped by default. Compression can be lossy and can produce a larger file than
the input while still meeting the limit.

## Project files and sharing

- `Image_Tool.bat`: the complete application and launcher.
- `ImageMagick/`: the portable image engine, configuration and license notices.
- `README.md`: user instructions.
- `AGENTS.md`: project context for future coding agents.
- `release/Console-Image-Tool-Portable.zip`: the ready-to-share package.
- `.gitignore`: excludes generated release ZIPs from Git tracking.

Send the ZIP in `release`; recipients extract it and run the batch file. There is
no build step or download needed to use the current package. Build caches and
test artifacts are not part of this project.

If the application is changed later, recreate the ZIP from the updated files:

```powershell
Compress-Archive -LiteralPath Image_Tool.bat, README.md, ImageMagick -DestinationPath release\Console-Image-Tool-Portable.zip -Force
```

ImageMagick 7.1.2-36 Q16 x64 is supplied by **ImageMagick Studio LLC**. Preserve the
engine's configuration, `LICENSE.txt`, `NOTICE.txt` and `SOURCE.json` when sharing
or updating it. `SOURCE.json` records the original archive URL and checksum. See
[ImageMagick](https://imagemagick.org/) and the
[official release](https://github.com/ImageMagick/ImageMagick/releases/tag/7.1.2-36).

If startup fails, the window displays the error and waits for Enter rather than
closing immediately. Include that error message when reporting a problem.
