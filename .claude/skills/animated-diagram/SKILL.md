---
name: animated-diagram
description: "Generate self-contained, dark-mode, premium developer-docs animated HTML/SVG diagrams. Use this whenever the user asks for an animated diagram, visual explanation, flow animation, system/process/architecture diagram, or concept visualization. Prioritize robust layout: no clipped objects, no overlaps, no orphan arrows, and simple safe scaffolds before decorative complexity."
version: 1.3.0
last_updated: 2026-06-24
---

# Animated Diagram Generator Skill

Generate one polished, self-contained `index.html` that visually explains a concept with inline HTML/SVG/CSS and minimal JavaScript.

## Output contract

Create exactly:

```text
index.html
```

The file must be:

- Standalone: no build step, package manager, CDN, remote fonts, remote images, external CSS, or external JS.
- Browser-native: semantic HTML, inline SVG for the diagram, CSS variables for theme/layout/motion.
- Dark-mode first.
- Accessible: SVG `<title>` + `<desc>`, visible pause/resume for loops, `prefers-reduced-motion`, no flashing/strobing.
- Minimal: 3-7 primary objects by default, short labels, one clear story.

If file access is available, start from `references/starter-template.html` and adapt it. The template is intentionally safer than freehand SVG: top-left card geometry, bounded safe areas, and a dark dotted-grid theme.

## Default visual style

Target look: premium CLI/developer-docs launch graphic.

Use:

- Deep navy/ink background, not flat black.
- Large rounded outer frame with thin blue-slate border.
- Subtle dotted-grid/starfield texture.
- Centered command/status pill with a teal dot.
- Large but bounded gradient title: periwinkle → violet → teal.
- Muted blue-gray subtitle.
- Rounded glass cards with low-opacity fills and thin colored strokes.
- Monospace micro-labels for captions, connector labels, badges, and chips.
- Thin connector rails with arrowheads, small waypoints, and 1-3 animated packets/pulses.
- Semantic colors:
  - blue/periwinkle = input/agent/source
  - purple = runtime/parallel/map/processing
  - amber = gate/decision/warning
  - teal/green = output/result/user context

Avoid:

- Neon cyberpunk overload.
- Cropped poster elements.
- Free-floating arrows with missing nodes.
- Rainbow palettes.
- Dense UML dumps.
- Mermaid/D2 as final output unless explicitly requested.

## Robustness-first layout rules

Most failures come from too much freestyle SVG. Do layout numerically before writing code.

Default SVG:

```html
<svg viewBox="0 0 1800 980" role="img" aria-labelledby="diagram-title diagram-desc">
```

Safe zones for `1800x980`:

```text
Outer SVG:        0..1800 x 0..980
Hard safe area:   x=120..1680, y=80..900
Hero zone:        x=220..1580, y=60..260
Diagram zone:     x=160..1640, y=330..780
Footer/chips:     x=220..1580, y=840..925
Left lane:        x=220..520
Middle lane:      x=680..1120
Right lane:       x=1280..1580
```

Hard rules:

1. No important object may be clipped or intentionally cropped.
2. No cards/panels/chips may start outside the hard safe area.
3. Prefer top-left geometry for cards:
   ```html
   <rect x="260" y="470" width="240" height="116" rx="22" />
   ```
   This is safer than translated groups with negative rect coordinates.
4. If using center-based geometry, verify:
   ```text
   centerX - width/2 >= 120
   centerX + width/2 <= 1680
   centerY - height/2 >= 80
   centerY + height/2 <= 900
   ```
5. Hero title must fit in the hero zone. If it wraps or touches the border, reduce size before adding diagram complexity.
6. Every connector must point to visible cards/nodes. No orphan arrows.
7. Footer chips are optional. Omit them if they would clip or crowd.
8. Prefer horizontal, vertical, or elbow connectors. Use long curves only when they clarify the story.

Recommended title CSS:

```css
h1 {
  font-size: clamp(2.7rem, 6.2vw, 6.2rem);
  line-height: 0.98;
  letter-spacing: -0.055em;
  text-wrap: balance;
  background: linear-gradient(90deg, #8fb4ff 0%, #b79cff 43%, #59e0b7 100%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}
```

## Safe scaffolds

For simple diagrams, choose one of these. Do not invent a complex freeform composition when a scaffold fits.

### A. Centered 3-step pipeline

Best for: “A becomes B becomes C”.

```text
[Card A] ─────────▶ [Card B] ─────────▶ [Card C]
x=260 y=470        x=780 y=470        x=1300 y=470
w=240 h=116        w=240 h=116        w=240 h=116
```

### B. Inputs → processor → result panel

Best for: one source/config creates many rendered outputs or a clean result.

```text
Inputs stack                  Processor boundary               Result panel
x=220 y=390 w=300 h=260       x=660 y=350 w=560 h=380           x=1320 y=390 w=300 h=260
```

Never crop the input stack off the left edge. Result panel should be green/teal.

### C. Before / after

Best for: refactor, migration, simplification, optimization.

```text
Before panel                         After panel
x=220 y=380 w=560 h=360              x=1020 y=380 w=560 h=360
```

One transform arrow between panels. No diagonal spaghetti.

### D. State row with one branch

Best for: job/order/status lifecycle.

```text
Queued → Running → Success
            ↓
        Failed/Retry
```

Keep all states inside one bounded rectangle. At most one retry branch unless the user asks for detail.

## Generation workflow

Before coding, internally create this brief:

```text
Concept:
Audience:
One-sentence story:
Scaffold/archetype:
Objects:
Relationships:
Layout table: id | role | x | y | w | h | anchors | notes
Motion idea:
What should be understood in 5 seconds:
What can be omitted:
```

Then code `index.html`.

Steps:

1. Clarify the teaching goal in one sentence.
2. Reduce to 3-7 primary objects.
3. Pick the simplest safe scaffold above.
4. Make the layout table before writing SVG.
5. Verify all object boxes fit inside safe zones.
6. Add labels: title, one-sentence subtitle, 1-4 word card labels, tiny connector captions only if useful.
7. Add motion for meaning only: packet travel, path reveal, active pulse, progress, or subtle halo.
8. Add pause/resume and reduced-motion support.
9. Run visual QA and fix before delivering.

## Motion rules

Good motion answers: where did it come from, where is it going, what is active, what changed, what depends on what?

Use at most 2-3 motion ideas at once. Prefer:

- packet travel along a connector
- active node pulse
- path reveal
- staggered card entrance
- slow halo around a hub/result

Avoid bounce/stretch easing, rapid flashing, shaking, or motion that merely decorates.

Default timings:

```text
Node entrance:        420-720ms
Path reveal:          900-1600ms
Packet travel:        2400-4800ms
Slow pulse/halo:      2400-5000ms
Full loop:            6000-12000ms
```

Always include:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.001ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.001ms !important;
    scroll-behavior: auto !important;
  }
  .motion-toggle { display: none; }
}
```

## Visual QA checklist

Before finishing, inspect the generated file. If browser/screenshot tools are available, render it and check the screenshot.

Must pass:

- [ ] Title is fully visible and not touching the frame.
- [ ] No card, panel, chip, label, arrowhead, or glow is clipped.
- [ ] Every connector has visible source/target objects.
- [ ] Labels do not overlap connectors, cards, arrowheads, badges, or other text.
- [ ] Diagram has a clear focal point and can be understood in 5 seconds.
- [ ] The dark dotted-grid theme is present but subtle.
- [ ] The blue/purple/teal/amber palette is used semantically and sparingly.
- [ ] Pause/resume works.
- [ ] Reduced-motion still leaves an understandable static diagram.
- [ ] `index.html` works offline with no console errors.

If any item fails, simplify: fewer objects, smaller title, wider spacing, straighter connectors, or remove optional chips/badges.

## References

- `references/starter-template.html` — robust self-contained starter with this theme and safe 3-card scaffold. Read/adapt it when generating a diagram.
- `references/legacy-overloaded-skill-2026-06-24.md` — archived old detailed version; do not read unless intentionally recovering old guidance.

## Final instruction

Produce one excellent, simple, robust visual story. The theme matters, but correctness of layout matters more: no clipping, no overlaps, no orphan arrows.
