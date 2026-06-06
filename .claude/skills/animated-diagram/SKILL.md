---
name: animated-diagram
description: Create a modern, minimal, aesthetic, self-contained animated HTML + SVG explainer for a concept. Use whenever the user asks for animated diagrams, visual explainers, concept explainers, mini interactive HTML/SVG illustrations, modern SVG diagrams, or a single-file index.html that teaches something visually.
---

# Animated Diagram

Create one polished `index.html` that explains a concept with a modern, minimal animated SVG diagram.

## Output contract

Unless the user asks otherwise:

- Create exactly one file: `index.html`.
- Make it open directly in a browser; no build step.
- Use only inline HTML, CSS, SVG, and optional tiny inline JavaScript.
- Do not use external dependencies, CDNs, fonts, images, React, D3, Mermaid, canvas, or network requests.
- Include a visible title, one-sentence subtitle, main diagram, and 3–5 short explanation cards.
- Include accessible SVG `<title>` and `<desc>` and a reduced-motion fallback.
- If file creation is unavailable, output the full `index.html` contents.

Final response should be brief:

```text
Created `index.html`.

Open it in your browser.
```

## Defaults

- Audience: beginner
- Depth: simple
- Style: modern dark mode, minimal constellation-card aesthetic
- Animation: enabled, but only when it teaches
- Interactivity: none unless useful for learning
- Diagram complexity: 4–7 main visual objects

## Before building

Silently decide:

1. The one-sentence lesson.
2. The audience and depth.
3. One visual metaphor.
4. One diagram pattern.
5. The 4–7 main objects.
6. The animation story: what moves, lights up, appears, or changes, and why.
7. The semantic meaning of each color.
8. The 3–5 explanation cards.

Do not expose this planning unless asked.

## Choose one diagram pattern

Use one primary structure. Do not mix patterns unless the concept truly needs it.

| Pattern | Use for | Animation idea |
|---|---|---|
| Flow | requests, pipelines, auth, CI/CD, RAG, networking | packet moves step by step |
| Layers | stacks, architecture, OS, cloud, protocols | layers fade in or activate |
| State machine | jobs, retries, failures, consensus, order states | token moves between states |
| Comparison | before/after, why a tool exists | messy side resolves into clean side |
| System map | distributed systems and component relationships | messages move between nodes |

Pick a metaphor that makes the concept obvious: conveyor belt, control room, library, traffic routing, queue, timeline, map, or voting circle. Stick to one metaphor.

## Visual style

Default to a modern constellation-card aesthetic: a dark atmospheric canvas with a few floating information cards connected by elegant hairline paths.

What matters most:

- Deep navy/black background with subtle radial glow, not a flat black fill.
- 4–7 floating rounded cards or pills, arranged asymmetrically but visually balanced.
- Thin 1–2px connector lines with occasional right-angle bends; keep them sparse and intentional.
- Small accent nodes: dots, tiny pills, plus signs, ticks, or short line segments that make the scene feel alive.
- Compact card interiors: short labels, 1–3 fake text strokes, or tiny drawable marks; never paragraphs.
- Restrained neon palette: one warm color, one cool color, one violet/pink accent, plus muted gray lines.
- Soft depth: subtle glow, light shadows, translucent strokes, and lots of negative space.
- Minimal motion: one packet, pulse, highlight, or reveal sequence that explains the concept.

Composition recipe:

- Put one focal card near the center, then scatter supporting cards around it with uneven spacing.
- Let connector lines pass behind cards; use small colored dots where lines start, end, or branch.
- Vary card sizes slightly so the layout has rhythm without feeling chaotic.
- Use micro-shapes sparingly as atmosphere, not content.
- Keep the center readable and the edges quieter.

Prefer abstract SVG primitives over realistic icons. The diagram can use any drawable shape or text-like mark as long as the visual story is clear.

Avoid:

- dense architecture maps or rigid grid layouts
- tiny labels or long SVG text
- decorative motion with no explanatory role
- random colors, heavy gradients, noisy particles, or vendor-poster aesthetics
- more than 7 main nodes for beginner diagrams

### Color language

Use colors consistently:

- Blue: control, decisions, APIs
- Green: success, healthy, running
- Amber: routing, service, attention
- Red: failure, retry, risk
- Violet: data, memory, storage
- Slate/gray: infrastructure, inactive parts

A good default palette:

```css
:root {
  --bg: #090d1a;
  --panel: rgba(15, 23, 42, 0.78);
  --panel-strong: rgba(17, 24, 39, 0.96);
  --border: rgba(148, 163, 184, 0.18);
  --text: #f8fafc;
  --muted: #a7b0c0;
  --line: rgba(148, 163, 184, 0.42);
  --blue: #60a5fa;
  --green: #34d399;
  --amber: #fbbf24;
  --red: #fb7185;
  --violet: #a78bfa;
}
```

## Animation rules

Animation must explain cause and effect.

Good animation:

- a request packet moving through a flow
- the active component softly lighting up
- layers appearing in order
- a job token moving through states
- a retry path becoming visible after failure
- desired state and actual state converging

Bad animation:

- bouncing, spinning, floating decoration
- too many simultaneous motions
- motion with no caption or meaning
- complex physics or distracting particles

Prefer CSS keyframes with a 12–30 second loop. Keep JavaScript optional and tiny: play/pause, next/back, or simple highlight only.

## Required HTML shape

Use this structure and adapt it to the concept:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title><!-- concept title --></title>
  <style>
    /* inline CSS only */
  </style>
</head>
<body>
  <main class="wrap">
    <header class="hero">
      <p class="eyebrow"><!-- optional category --></p>
      <h1><!-- title --></h1>
      <p class="subtitle"><!-- one-sentence explanation --></p>
    </header>

    <section class="diagram-card" aria-label="Animated concept diagram">
      <svg role="img" aria-labelledby="diagram-title diagram-desc" viewBox="0 0 1200 700">
        <title id="diagram-title"><!-- short accessible title --></title>
        <desc id="diagram-desc"><!-- one-sentence accessible description --></desc>
        <!-- defs, lines, nodes, labels, captions, animated elements -->
      </svg>
    </section>

    <section class="explanation">
      <!-- 3-5 concise cards -->
    </section>
  </main>
</body>
</html>
```

## CSS baseline

Start from this compact baseline, then customize colors, layout, and animations for the concept.

```css
* { box-sizing: border-box; }

body {
  margin: 0;
  min-height: 100vh;
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  color: var(--text);
  background:
    radial-gradient(circle at 18% 12%, rgba(96, 165, 250, 0.22), transparent 32%),
    radial-gradient(circle at 82% 8%, rgba(167, 139, 250, 0.16), transparent 30%),
    linear-gradient(180deg, #0b1020 0%, var(--bg) 100%);
  display: grid;
  place-items: center;
  padding: 28px;
}

.wrap { width: min(1120px, 100%); }

.hero { margin-bottom: 18px; }

.eyebrow {
  margin: 0 0 10px;
  color: var(--blue);
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.16em;
  text-transform: uppercase;
}

h1 {
  margin: 0;
  font-size: clamp(32px, 6vw, 64px);
  letter-spacing: -0.06em;
  line-height: 0.95;
}

.subtitle {
  max-width: 760px;
  margin: 14px 0 0;
  color: var(--muted);
  font-size: clamp(16px, 2vw, 19px);
  line-height: 1.6;
}

.diagram-card {
  overflow: hidden;
  border: 1px solid var(--border);
  border-radius: 28px;
  background: linear-gradient(180deg, rgba(15, 23, 42, 0.88), rgba(15, 23, 42, 0.62));
  box-shadow: 0 30px 90px rgba(0, 0, 0, 0.42);
  backdrop-filter: blur(14px);
}

svg { display: block; width: 100%; height: auto; }

.node {
  fill: var(--panel-strong);
  stroke: var(--border);
  stroke-width: 2;
}

.label {
  fill: var(--text);
  font-size: 18px;
  font-weight: 800;
}

.small {
  fill: var(--muted);
  font-size: 13px;
}

.line {
  fill: none;
  stroke: var(--line);
  stroke-width: 3;
  stroke-linecap: round;
  stroke-dasharray: 8 10;
}

.explanation {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-top: 14px;
}

.note {
  border: 1px solid var(--border);
  border-radius: 18px;
  background: rgba(15, 23, 42, 0.58);
  padding: 16px;
}

.note b { display: block; margin-bottom: 6px; }
.note span { color: var(--muted); font-size: 14px; line-height: 1.5; }

@media (max-width: 780px) {
  body { padding: 16px; }
  .explanation { grid-template-columns: 1fr; }
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.001ms !important;
    animation-iteration-count: 1 !important;
    scroll-behavior: auto !important;
  }
}
```

## Explanation cards

Keep cards short and conceptual:

```html
<section class="explanation">
  <div class="note">
    <b>Request enters</b>
    <span>The system receives one clear input and decides where it should go.</span>
  </div>
  <div class="note">
    <b>Work happens</b>
    <span>The active component transforms, stores, routes, or validates the input.</span>
  </div>
  <div class="note">
    <b>Result returns</b>
    <span>The user sees the outcome without needing the internal details.</span>
  </div>
</section>
```

## Quality checklist

Before finishing, verify:

- `index.html` exists and opens directly in a browser.
- The file is fully self-contained with no external requests.
- The SVG has `role="img"`, `<title>`, and `<desc>`.
- The diagram has one mental model, one primary pattern, and 4–7 main objects.
- Labels are readable and short.
- Animation teaches causality rather than decoration.
- Reduced-motion CSS exists.
- Mobile layout works.
- The result looks modern, minimal, aesthetic, and uncluttered.
