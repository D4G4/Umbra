# Umbra

Casts a subtle, adjustable shadow over your static menu bar and Dock to ease OLED
wear — clearing the instant your cursor is over them. A lightweight menu-bar agent
for high-end OLED displays (built for an LG 39GX950B-B, works on any Mac).

## How it works (and why it dims, not brightens)

OLED burn-in is differential sub-pixel aging, roughly proportional to
∫ luminance·dt — so the only thing a compositing overlay can do to *slow* aging
is **subtract** luminance from static regions. Adding light (a bright overlay)
would raise the emitted luminance and make aging *worse*. So Umbra draws a
subtle, **steady dark scrim** — never lighter than the background, and never blue
(the fastest-aging channel). There's deliberately no animation: moving the dark
layer can't relocate the bright menu-bar/Dock content, so it wouldn't reduce
differential aging — a consistent dim lowers average luminance the most.

Both are transparent, **click-through** overlays (window level 26, above
the menu bar's status items and the Dock, below dropdown menus — native menus and
Control Center stay clickable):

- **Menu Bar** — over the primary display's menu bar.
- **Dock** — over the Dock strip, whose edge (bottom / left / right) and size are
  auto-detected from the screen's reserved band. Off by default.

Each overlay lives on the desktop Space, so it disappears in fullscreen; the dim
is lifted while your cursor is over the strip so you can read and click it.

**You set the depth.** A single **Dimming** slider (0–50%) sets how dark the
scrim is; it clears the moment your cursor is over the strip, then re-dims when
you leave. A live caption tells you what each level suits.

Umbra runs as a pure background agent (`LSUIElement`) — no Dock icon, no Cmd-Tab
entry, ever.

## Dimming slider

One slider sets the scrim darkness (0–50%), with a caption that updates as you drag:

| Range | Reads as | For |
|-------|----------|-----|
| ~0–8% | Barely there | Tandem OLED, low-risk panels |
| ~8–20% | Light | Most OLED displays, everyday use |
| ~20–35% *(default 22%)* | Noticeable | Regular WOLED / QD-OLED prone to retention |
| ~35–50% | Heavy | High-risk static UIs — clearly darker |

## Honest note on effectiveness

The dimming mechanism is physically real, but the magnitude is modest — and on a
**Tandem OLED** (dual emission layer, e.g. the LG 39GX950B) the panel already
halves per-layer stress, so the benefit there is small. It matters more on
regular single-layer WOLED / QD-OLED. The biggest wins are native anyway:
dark-mode menu bar, auto-hiding Dock, lower panel brightness, and the display's
own pixel-shift/compensation. Treat Umbra as a modest dimming aid, not
guaranteed burn-in "protection."

## Controls

Click the menu-bar icon for: Menu Bar on/off, Dock on/off, the Dimming slider,
Launch at Login, Open Log, Quit. A welcome
window appears at launch (toggle it off there).

## Build

```sh
brew install xcodegen        # one-time
xcodegen generate            # writes Umbra.xcodeproj (gitignored)
open Umbra.xcodeproj    # build & run the Umbra scheme
# or headless:
xcodebuild -project Umbra.xcodeproj -scheme Umbra -configuration Debug build
```

Requires macOS 14+.
