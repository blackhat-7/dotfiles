---
name: animated-diagram
description: Generate self-contained, dark-mode, modern, minimal animated HTML/SVG diagrams that explain any concept clearly.
version: 1.0.0
last_updated: 2026-06-06
---

# Animated Diagram Generator Skill

## Purpose

Use this skill when the user asks for an animated diagram, visual explanation, explorable explanation, flow animation, system diagram, process diagram, architecture animation, concept visualization, or a simple visual story.

The goal is to generate diagrams that are:

- **Minimal**: only the essential objects, labels, and motion.
- **Modern**: dark mode, soft contrast, tasteful gradients, rounded geometry, subtle glow.
- **Simple to view**: one standalone `index.html` file that opens directly in a browser.
- **Aesthetic**: polished enough to feel like a high-quality product explainer.
- **General-purpose**: usable for software architecture, code flow, Kubernetes, databases, making tea, biology, money flow, abstract concepts, or any other process/system.

The default output is **HTML + inline SVG + CSS**, with tiny optional JavaScript only for controls such as pause/resume, step navigation, or scrubbing.

---

## Non-negotiable output contract

When generating a diagram, create:

```text
index.html
```

The file must be:

1. **Standalone**
   - No build step.
   - No package manager.
   - No CDN.
   - No remote fonts.
   - No remote images.
   - No external CSS or JavaScript.
   - User can open it with `open index.html`, double-click it, or serve it with any static file server.

2. **Browser-native**
   - Use semantic HTML.
   - Use inline SVG for the actual diagram.
   - Use CSS variables for theme, layout, and motion tokens.
   - Use CSS animations for most animation.
   - Use JavaScript only when interaction is genuinely useful.

3. **Dark-mode first**
   - The diagram must look intentional on a dark background.
   - Do not generate a light theme unless the user explicitly asks.

4. **Minimal**
   - Default to 3-7 primary objects.
   - Default to 1-2 accent colors.
   - Default to 1 headline and 1 short explanatory subtitle.
   - Labels should usually be 1-4 words.
   - No dense UML dumps, huge legends, rainbow palettes, or verbose paragraphs inside the canvas.

5. **Accessible**
   - Include `<title>` and `<desc>` inside the SVG.
   - Respect `prefers-reduced-motion`.
   - Provide a visible pause/resume control for looping animations.
   - Do not use rapid flashing, strobing, shaking, or nausea-inducing zooms.
   - Do not communicate important state using color alone; also use labels, symbols, position, or motion.

6. **Polished**
   - Use a balanced layout.
   - Use consistent spacing.
   - Use subtle animation; motion must clarify, not decorate.
   - Check that text is readable on the background.
   - Check that the diagram makes sense within 5 seconds.

---

## Research-distilled design philosophy

This skill is based on the following observations from modern motion, diagramming, and explorable-explanation systems:

- SVG is ideal for this output because it is a text-based web standard, scales cleanly, and works with CSS, DOM, JavaScript, and browser rendering.
- Effective motion should guide attention and explain relationships, not exist as decoration.
- Motion should be subtle, human, performant, and accessible.
- Easing matters: linear motion often feels mechanical; use fast starts and soft landings for natural motion.
- Avoid bounce/stretch/sudden-stop easing unless the concept truly requires it.
- Good explanations usually start with a small mechanism, then build up to the whole system.
- Text-to-diagram tools such as Mermaid and D2 are useful references for structure, but this skill should usually output custom HTML/SVG for better aesthetics and animation control.
- Excalidraw-style hand-drawn diagrams are approachable, but this skill's default aesthetic is cleaner: dark, geometric, minimal, product-like.
- Explorable explanations are strongest when the viewer can see cause and effect, not just final structure.

---

## Default aesthetic

### Overall look

Think: **minimal developer-docs meets premium SaaS landing page**.

Use:

- Deep charcoal / near-black background.
- Subtle radial glow behind the main diagram.
- Rounded translucent cards.
- Thin connector lines.
- Small animated packets, pulses, sweeps, or progress indicators.
- Soft shadows and glows, never neon overload.
- System font stack, not decorative fonts.

Avoid:

- Cartoonish colors.
- Excessive particles.
- 3D unless requested.
- Photorealism.
- Heavy textures.
- Overly hand-drawn style.
- Big icon packs.
- Complex dashboards.
- Mermaid default styling.

### Theme tokens

Use these as the default starting point:

```css
:root {
  color-scheme: dark;

  --bg-0: #05070d;
  --bg-1: #080b14;
  --panel: rgba(15, 23, 42, 0.72);
  --panel-strong: rgba(17, 24, 39, 0.92);
  --stroke: rgba(148, 163, 184, 0.22);
  --stroke-strong: rgba(203, 213, 225, 0.34);

  --text: #e5eefb;
  --muted: #8fa1b7;
  --faint: #536274;

  --accent: #7dd3fc;
  --accent-2: #c084fc;
  --accent-3: #86efac;
  --warn: #fbbf24;
  --danger: #fb7185;

  --radius-sm: 10px;
  --radius-md: 16px;
  --radius-lg: 24px;

  --shadow-soft: 0 18px 70px rgba(0, 0, 0, 0.38);
  --glow: 0 0 28px rgba(125, 211, 252, 0.20);

  --ease-out: cubic-bezier(0, 0.4, 0, 1);
  --ease-standard: cubic-bezier(0.2, 0, 0.38, 0.9);
  --ease-soft: cubic-bezier(0.16, 1, 0.3, 1);

  --dur-fast: 160ms;
  --dur-med: 360ms;
  --dur-slow: 720ms;
}
```

### Typography

Use:

```css
font-family:
  Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
  "Segoe UI", sans-serif;
```

Do not import Inter. The browser will fall back to system fonts.

Recommended sizes:

```css
.hero-title {
  font-size: clamp(1.35rem, 2.4vw, 2.6rem);
  line-height: 1.08;
  letter-spacing: -0.035em;
}

.hero-subtitle {
  font-size: clamp(0.88rem, 1.15vw, 1.0rem);
  line-height: 1.5;
  color: var(--muted);
}

.node-label {
  font-size: 14px;
  font-weight: 650;
}

.edge-label {
  font-size: 12px;
  color: var(--muted);
}
```

### Layout

Default SVG viewBox:

```html
<svg viewBox="0 0 1600 900" role="img" aria-labelledby="diagram-title diagram-desc">
```

Use the viewport generously. Do **not** artificially cap the diagram at 1120px wide for normal desktop screens; the stage should usually be between 1600px and 1800px wide on large displays, e.g. `width: min(1720px, calc(100vw - 32px));`, and the SVG should take most of the visible page. Use a 16px or 24px spacing rhythm. Keep key objects away from edges.

Common coordinate zones:

```text
Header text: outside SVG, above diagram, usually <= 15-18vh
SVG safe area: x=110..1490, y=90..810
Main center: 800, 450
Left lane: x=220..470
Middle lane: x=600..1000
Right lane: x=1130..1380
```

Space and anti-overlap rules:

- Expand the canvas/viewBox before shrinking text or allowing clutter.
- For dense diagrams, upgrade to `1800x1000`, `2000x1125`, or a taller full-page SVG if needed.
- Prefer a slightly scrollable full-page diagram over tiny labels or crowded cards.
- Keep at least 24px between unrelated objects, 32-48px between cards and connector labels, and 12-16px internal padding around text.
- Route connectors around cards; never let labels sit under boxes, edges, or arrowheads.
- If a label needs more than 1-4 words, wrap it inside a wider card or move details into a subtitle/note outside the SVG.
- Before finalizing, scan the SVG for text/card overlaps and fix them by increasing spacing, moving lanes, or reducing object count.

---

## Diagram archetypes

Choose one archetype before writing code. Do not force all concepts into a generic flowchart.

### 1. Pipeline / flow

Use for: request lifecycle, CI/CD, cooking steps, data pipelines, onboarding, payment processing.

Layout:

```text
[Input] → [Step 1] → [Step 2] → [Output]
```

Motion:

- Small glowing token travels along edges.
- Current node gently pulses as token arrives.
- Optional progress rail under the pipeline.

Best for: "how X moves through Y."

---

### 2. Layered stack

Use for: OSI layers, app architecture, Kubernetes layers, AI stack, business hierarchy.

Layout:

```text
┌ User / Interface ┐
┌ Service layer    ┐
┌ Data layer       ┐
┌ Infrastructure   ┐
```

Motion:

- Layers reveal bottom-to-top or top-to-bottom.
- Thin vertical "request beam" passes through layers.
- Active layer gets a subtle rim glow.

Best for: "what sits above/below what."

---

### 3. Hub and spoke

Use for: central orchestrator, API gateway, message broker, brain/body systems, marketplace.

Layout:

```text
        [A]
         |
[B] — [Hub] — [C]
         |
        [D]
```

Motion:

- Packets move into hub, transform, then fan out.
- Hub has a slow breathing halo.
- Use staggered spoke animations.

Best for: "one thing coordinates many things."

---

### 4. Sequence / conversation

Use for: client-server, auth handshake, protocols, Slack bot workflow, human conversation.

Layout:

```text
Actor A        Actor B        Actor C
  |              |              |
  |── message ──>|              |
  |<─ response ──|              |
```

Motion:

- Horizontal message chips slide across lanes.
- Vertical lifelines are faint.
- Current message row brightens.

Best for: "who talks to whom, in what order."

---

### 5. State machine

Use for: job lifecycle, order status, retries, finite automata, training pipeline states.

Layout:

```text
Queued → Running → Succeeded
   ↘       ↓
    Retry ← Failed
```

Motion:

- Active state ring moves around nodes.
- Edges glow in sequence.
- Failed/retry branch is muted unless important.

Best for: "how states change."

---

### 6. Timeline / staged reveal

Use for: historical events, learning path, incident response, project plan, recipe steps.

Layout:

```text
1 ───── 2 ───── 3 ───── 4
```

Motion:

- Progress line draws across.
- Step cards fade/slide in.
- Current stage marker expands.

Best for: "what happens first, second, third."

---

### 7. Causal loop / feedback system

Use for: flywheel, compounding, learning loop, monitoring loop, economics, habit formation.

Layout:

```text
A → B → C → D
↑           ↓
└───────────┘
```

Motion:

- Dot loops around the cycle.
- Each node briefly brightens.
- Use arrows and one feedback label.

Best for: "why this keeps reinforcing itself."

---

### 8. Spatial sandbox

Use for: physics, networks, load balancing, traffic, resource allocation, swarm behavior.

Layout:

- Place objects in a field, not a strict flowchart.
- Use trails, fields, rings, or gravity-like arcs.
- Keep labels minimal.

Motion:

- Bodies drift or orbit slowly.
- Ghost trails show history.
- Sliders are optional, only if useful.

Best for: "how things behave in a space."

---

### 9. Before / after transformation

Use for: optimization, refactoring, compression, simplification, queue draining, data cleaning.

Layout:

```text
Before                 After
messy cluster   →      clean structure
```

Motion:

- Messy elements converge into ordered layout.
- Use one transform arrow.
- Add a short "why it improved" label.

Best for: "how X becomes Y."

---

### 10. Decision / branching

Use for: troubleshooting, routing, diagnosis, "what should I choose?", if/else logic.

Layout:

```text
Question
  ├─ yes → path A
  └─ no  → path B
```

Motion:

- Decision node pulses.
- One route lights up at a time.
- Use labels on branches.

Best for: "what happens depending on a condition."

---

## Choosing the archetype

Use this decision table:

```text
Does something move from start to end?       → Pipeline
Are there vertical abstraction levels?       → Layered stack
Is one thing coordinating many things?       → Hub and spoke
Is the story about messages over time?       → Sequence
Is the story about statuses?                 → State machine
Is the story chronological?                  → Timeline
Is there a reinforcing cycle?                → Causal loop
Does physical/spatial intuition matter?      → Spatial sandbox
Is the point simplification or conversion?   → Before/after
Is there a condition or choice?              → Decision tree
```

If two archetypes fit, pick the one that makes the concept understandable fastest.

---

## Generation workflow for the AI harness

Before writing code, internally create this brief:

```text
Concept:
Audience:
One-sentence story:
Archetype:
Objects:
Relationships:
Motion idea:
What should be understood in 5 seconds:
What can be omitted:
```

Then generate the file.

### Step-by-step

1. **Clarify the teaching goal**
   - Convert the user's request into one sentence.
   - Example: "Kubernetes keeps apps running by scheduling containers onto machines and replacing failed ones."

2. **Pick one visual metaphor**
   - Use "packets", "tokens", "steam", "signals", "requests", "energy", "jobs", "ingredients", or "messages".
   - Do not mix too many metaphors.

3. **Reduce**
   - Remove anything that does not help the core story.
   - For software systems, collapse internal details into one card when possible.

4. **Storyboard**
   - Frame 1: resting system.
   - Frame 2: action begins.
   - Frame 3: transformation/result.
   - Frame 4: loop resets smoothly, if looping.

5. **Layout**
   - Use the archetype's geometry.
   - Align cards to a grid.
   - Keep connector crossings near zero.

6. **Animate**
   - Use no more than 2-3 simultaneous motion ideas.
   - Prefer packet travel, highlight, reveal, progress, orbit, or pulse.
   - Use staggered delays to guide attention.

7. **Add microcopy**
   - Title: what the diagram explains.
   - Subtitle: one sentence.
   - Labels: short nouns/verbs.
   - Optional note: one tiny explanatory note.

8. **Add controls**
   - Always include pause/resume for looping animations.
   - Include step buttons only if the diagram is a multi-step lesson.

9. **Run QA**
   - Check visual balance.
   - Check reduced motion.
   - Check that the diagram uses most of the available viewport on desktop instead of floating in a small 1120px island.
   - Check that the diagram works at 800px wide and 1600px+ wide.
   - Check that labels do not overlap cards, connectors, arrowheads, badges, or other text.
   - Check that the animation tells the story even without reading every label.

---

## Animation language

### Use motion for meaning

Good animation answers at least one of these:

- Where did this come from?
- Where is it going?
- What is active right now?
- What changed?
- What depends on what?
- What repeats?
- What is the bottleneck?
- What is hidden unless highlighted?

Bad animation merely says: "look, something is moving."

### Default motion tokens

```css
:root {
  --ease-out: cubic-bezier(0, 0.4, 0, 1);
  --ease-standard: cubic-bezier(0.2, 0, 0.38, 0.9);
  --ease-soft: cubic-bezier(0.16, 1, 0.3, 1);

  --dur-instant: 90ms;
  --dur-fast: 160ms;
  --dur-med: 360ms;
  --dur-slow: 720ms;
  --loop-short: 2400ms;
  --loop-med: 4200ms;
  --loop-long: 7000ms;
}
```

### Recommended durations

```text
Hover/press response:       90-160ms
Node entrance:              420-720ms
Stagger between nodes:      70-120ms
Path draw:                  900-1600ms
Packet travel:              2400-4800ms
Slow halo/pulse:            2400-5000ms
Full explanatory loop:      6000-12000ms
Step transition:            300-600ms
```

### Recommended animation patterns

#### 1. Staggered node entrance

Use once at page load.

```css
.node {
  opacity: 0;
  transform-box: fill-box;
  transform-origin: center;
  animation: node-enter 640ms var(--ease-out) forwards;
  animation-delay: calc(var(--i) * 90ms);
}

@keyframes node-enter {
  from { opacity: 0; transform: translateY(10px) scale(0.98); }
  to   { opacity: 1; transform: translateY(0) scale(1); }
}
```

#### 2. Path reveal

Good for showing structure before tokens move.

```css
.edge.reveal {
  stroke-dasharray: 1;
  stroke-dashoffset: 1;
  animation: path-reveal 1200ms var(--ease-soft) forwards;
}

@keyframes path-reveal {
  to { stroke-dashoffset: 0; }
}
```

Use `pathLength="1"` on the SVG path.

#### 3. Packet travel

Good for flow, sequence, pipelines, and networks.

```css
.packet {
  offset-path: path("M 220 340 C 390 260, 510 260, 680 340 S 950 420, 1040 340");
  offset-rotate: 0deg;
  animation: travel 4200ms var(--ease-standard) infinite;
  filter: drop-shadow(0 0 12px rgba(125, 211, 252, 0.55));
}

.packet:nth-of-type(2) {
  animation-delay: -1400ms;
  opacity: 0.65;
}

@keyframes travel {
  0%   { offset-distance: 0%; opacity: 0; transform: scale(0.75); }
  8%   { opacity: 1; transform: scale(1); }
  88%  { opacity: 1; }
  100% { offset-distance: 100%; opacity: 0; transform: scale(0.75); }
}
```

For maximum compatibility in very old browsers, replace motion-path packets with simple `transform: translate(...)` keyframes along straight segments.

#### 4. Active node pulse

Use sparingly. Only pulse the currently important node.

```css
.node.active .node-shell {
  animation: active-pulse 2400ms var(--ease-soft) infinite;
}

@keyframes active-pulse {
  0%, 100% {
    stroke: rgba(125, 211, 252, 0.26);
    filter: drop-shadow(0 0 0 rgba(125, 211, 252, 0));
  }
  50% {
    stroke: rgba(125, 211, 252, 0.72);
    filter: drop-shadow(0 0 18px rgba(125, 211, 252, 0.25));
  }
}
```

#### 5. Handoff

Good for sequential systems.

```css
.handoff-a { animation-delay: 0ms; }
.handoff-b { animation-delay: 900ms; }
.handoff-c { animation-delay: 1800ms; }
```

Each node briefly highlights when the packet reaches it.

#### 6. Breathing halo

Good for central hubs, orchestrators, schedulers, control planes.

```css
.halo {
  transform-box: fill-box;
  transform-origin: center;
  animation: breathe 3600ms var(--ease-soft) infinite;
}

@keyframes breathe {
  0%, 100% { opacity: 0.15; transform: scale(0.96); }
  50%      { opacity: 0.38; transform: scale(1.04); }
}
```

#### 7. Ghost trail

Good for spatial or physics diagrams.

```css
.trail {
  opacity: 0.2;
  stroke-dasharray: 4 10;
  animation: trail-flow 1800ms linear infinite;
}

@keyframes trail-flow {
  to { stroke-dashoffset: -28; }
}
```

Use trails sparingly; too many trails become noisy.

---

## Interaction rules

The default diagram should work without interaction. Add interaction only when it helps comprehension.

Allowed interactions:

- Pause/resume motion.
- Step through stages.
- Hover a node to reveal one short explanation.
- Drag a slider for a parameter in an explorable/sandbox diagram.

Avoid:

- Complex sidebars.
- Nested menus.
- Tooltips that hide critical information.
- Required clicks before the diagram can be understood.
- Zoom/pan unless the user requested a large map.

### Pause/resume control

Every looping diagram should include:

```html
<button class="motion-toggle" type="button" aria-pressed="false">
  Pause motion
</button>
```

And simple JS:

```js
const button = document.querySelector(".motion-toggle");
const animated = document.querySelectorAll(".diagram *");

button?.addEventListener("click", () => {
  const paused = document.documentElement.classList.toggle("motion-paused");
  button.textContent = paused ? "Resume motion" : "Pause motion";
  button.setAttribute("aria-pressed", String(paused));

  animated.forEach((el) => {
    el.style.animationPlayState = paused ? "paused" : "running";
  });
});
```

Also include CSS:

```css
.motion-paused .diagram * {
  animation-play-state: paused !important;
}
```

---

## Reduced-motion rules

Always include:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.001ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.001ms !important;
    scroll-behavior: auto !important;
  }

  .packet {
    opacity: 0.9;
  }

  .motion-toggle {
    display: none;
  }
}
```

For reduced motion, the final state must still be understandable. Do not make the diagram depend on an animation that disappears entirely.

---

## SVG primitives

Use primitives like these instead of ad-hoc styling.

### Node card

```html
<g class="node" transform="translate(240 340)" style="--i: 0">
  <rect class="node-shell" x="-82" y="-38" width="164" height="76" rx="18" />
  <text class="node-title" x="0" y="-4" text-anchor="middle">Input</text>
  <text class="node-caption" x="0" y="18" text-anchor="middle">raw signal</text>
</g>
```

```css
.node-shell {
  fill: rgba(15, 23, 42, 0.82);
  stroke: rgba(148, 163, 184, 0.24);
  stroke-width: 1.2;
}

.node-title {
  fill: var(--text);
  font-size: 15px;
  font-weight: 700;
}

.node-caption {
  fill: var(--muted);
  font-size: 11px;
  font-weight: 500;
}
```

### Connector

```html
<path class="edge reveal" pathLength="1" d="M 322 340 C 400 340, 430 340, 508 340" />
```

```css
.edge {
  fill: none;
  stroke: rgba(148, 163, 184, 0.32);
  stroke-width: 2;
  stroke-linecap: round;
}
```

### Arrow marker

```html
<defs>
  <marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5"
          markerWidth="6" markerHeight="6" orient="auto-start-reverse">
    <path d="M 0 0 L 10 5 L 0 10 z" fill="rgba(148, 163, 184, 0.55)" />
  </marker>
</defs>
```

Then:

```html
<path class="edge" marker-end="url(#arrow)" d="M 322 340 C 400 340, 430 340, 508 340" />
```

### Packet

```html
<circle class="packet" r="5" cx="0" cy="0" />
```

```css
.packet {
  fill: var(--accent);
}
```

### Badge

```html
<g class="badge" transform="translate(600 92)">
  <rect x="-72" y="-16" width="144" height="32" rx="16" />
  <text x="0" y="5" text-anchor="middle">control loop</text>
</g>
```

---

## Full starter template

Use this as the base for most generated diagrams. Replace the title, subtitle, nodes, paths, and labels for the requested concept. The template intentionally uses a large canvas and a compact title area so diagrams can breathe on wide screens.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Animated Diagram</title>
  <style>
    :root {
      color-scheme: dark;
      --bg-0: #05070d;
      --bg-1: #080b14;
      --panel: rgba(15, 23, 42, 0.72);
      --panel-strong: rgba(17, 24, 39, 0.92);
      --stroke: rgba(148, 163, 184, 0.22);
      --stroke-strong: rgba(203, 213, 225, 0.34);
      --text: #e5eefb;
      --muted: #8fa1b7;
      --faint: #536274;
      --accent: #7dd3fc;
      --accent-2: #c084fc;
      --accent-3: #86efac;
      --radius-lg: 24px;
      --shadow-soft: 0 18px 70px rgba(0, 0, 0, 0.38);
      --ease-out: cubic-bezier(0, 0.4, 0, 1);
      --ease-standard: cubic-bezier(0.2, 0, 0.38, 0.9);
      --ease-soft: cubic-bezier(0.16, 1, 0.3, 1);
    }

    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      min-height: 100vh;
      overflow-x: hidden;
      display: grid;
      place-items: center;
      background:
        radial-gradient(circle at 20% 10%, rgba(125, 211, 252, 0.16), transparent 30%),
        radial-gradient(circle at 80% 20%, rgba(192, 132, 252, 0.13), transparent 32%),
        radial-gradient(circle at 50% 95%, rgba(134, 239, 172, 0.08), transparent 34%),
        linear-gradient(180deg, var(--bg-1), var(--bg-0));
      color: var(--text);
      font-family:
        Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
        "Segoe UI", sans-serif;
    }

    .stage {
      width: min(1720px, calc(100vw - 32px));
      min-height: 100vh;
      display: grid;
      grid-template-rows: auto minmax(0, 1fr);
      align-content: center;
      padding: clamp(16px, 2vw, 28px);
    }

    .hero {
      display: flex;
      justify-content: space-between;
      gap: clamp(16px, 2vw, 28px);
      align-items: end;
      margin: 0 0 clamp(12px, 1.4vh, 18px);
    }

    .eyebrow {
      margin: 0 0 10px;
      color: var(--accent);
      font-size: 0.75rem;
      font-weight: 800;
      letter-spacing: 0.16em;
      text-transform: uppercase;
    }

    h1 {
      margin: 0;
      max-width: 980px;
      font-size: clamp(1.45rem, 2.6vw, 2.7rem);
      line-height: 1.08;
      letter-spacing: -0.04em;
    }

    .subtitle {
      margin: 10px 0 0;
      max-width: 920px;
      color: var(--muted);
      font-size: clamp(0.9rem, 1.15vw, 1.02rem);
      line-height: 1.55;
    }

    .motion-toggle {
      appearance: none;
      border: 1px solid var(--stroke);
      border-radius: 999px;
      background: rgba(15, 23, 42, 0.70);
      color: var(--text);
      padding: 10px 14px;
      font: inherit;
      font-size: 0.85rem;
      cursor: pointer;
      box-shadow: var(--shadow-soft);
    }

    .motion-toggle:hover {
      border-color: var(--stroke-strong);
      background: rgba(30, 41, 59, 0.72);
    }

    .canvas {
      position: relative;
      overflow: hidden;
      border: 1px solid var(--stroke);
      border-radius: var(--radius-lg);
      background:
        linear-gradient(180deg, rgba(15, 23, 42, 0.82), rgba(2, 6, 23, 0.86)),
        radial-gradient(circle at 50% 45%, rgba(125, 211, 252, 0.10), transparent 42%);
      box-shadow: var(--shadow-soft);
    }

    svg {
      display: block;
      width: 100%;
      height: auto;
    }

    .grid {
      opacity: 0.18;
    }

    .grid line {
      stroke: rgba(148, 163, 184, 0.14);
      stroke-width: 1;
    }

    .edge {
      fill: none;
      stroke: rgba(148, 163, 184, 0.32);
      stroke-width: 2;
      stroke-linecap: round;
    }

    .edge.reveal {
      stroke-dasharray: 1;
      stroke-dashoffset: 1;
      animation: path-reveal 1200ms var(--ease-soft) forwards;
      animation-delay: 320ms;
    }

    .node {
      opacity: 0;
      transform-box: fill-box;
      transform-origin: center;
      animation: node-enter 640ms var(--ease-out) forwards;
      animation-delay: calc(var(--i) * 90ms);
    }

    .node-shell {
      fill: rgba(15, 23, 42, 0.84);
      stroke: rgba(148, 163, 184, 0.24);
      stroke-width: 1.2;
    }

    .node.active .node-shell {
      animation: active-pulse 2600ms var(--ease-soft) infinite;
      animation-delay: 1000ms;
    }

    .node-title {
      fill: var(--text);
      font-size: 15px;
      font-weight: 750;
      letter-spacing: -0.01em;
    }

    .node-caption {
      fill: var(--muted);
      font-size: 11px;
      font-weight: 550;
    }

    .packet {
      fill: var(--accent);
      opacity: 0;
      offset-path: path("M 320 450 C 545 325, 690 325, 800 450 S 1055 575, 1280 450");
      offset-rotate: 0deg;
      animation: travel 4400ms var(--ease-standard) infinite;
      filter: drop-shadow(0 0 12px rgba(125, 211, 252, 0.58));
    }

    .packet.two {
      fill: var(--accent-2);
      animation-delay: -1450ms;
      opacity: 0.65;
    }

    .packet.three {
      fill: var(--accent-3);
      animation-delay: -2900ms;
      opacity: 0.50;
    }

    .badge rect {
      fill: rgba(2, 6, 23, 0.54);
      stroke: rgba(148, 163, 184, 0.20);
    }

    .badge text {
      fill: var(--muted);
      font-size: 12px;
      font-weight: 700;
      letter-spacing: 0.06em;
      text-transform: uppercase;
    }

    @keyframes node-enter {
      from {
        opacity: 0;
        transform: translateY(10px) scale(0.985);
      }
      to {
        opacity: 1;
        transform: translateY(0) scale(1);
      }
    }

    @keyframes path-reveal {
      to {
        stroke-dashoffset: 0;
      }
    }

    @keyframes active-pulse {
      0%, 100% {
        stroke: rgba(125, 211, 252, 0.25);
        filter: drop-shadow(0 0 0 rgba(125, 211, 252, 0));
      }
      50% {
        stroke: rgba(125, 211, 252, 0.72);
        filter: drop-shadow(0 0 20px rgba(125, 211, 252, 0.24));
      }
    }

    @keyframes travel {
      0% {
        offset-distance: 0%;
        opacity: 0;
        transform: scale(0.72);
      }
      8% {
        opacity: 1;
        transform: scale(1);
      }
      88% {
        opacity: 1;
      }
      100% {
        offset-distance: 100%;
        opacity: 0;
        transform: scale(0.72);
      }
    }

    .motion-paused .diagram * {
      animation-play-state: paused !important;
    }

    @media (max-width: 760px) {
      .stage {
        width: min(100vw, 100%);
        padding: 18px;
      }

      .hero {
        align-items: start;
        flex-direction: column;
      }

      .motion-toggle {
        align-self: flex-start;
      }
    }

    @media (prefers-reduced-motion: reduce) {
      *,
      *::before,
      *::after {
        animation-duration: 0.001ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.001ms !important;
        scroll-behavior: auto !important;
      }

      .packet {
        opacity: 0.9;
      }

      .motion-toggle {
        display: none;
      }
    }
  </style>
</head>
<body>
  <main class="stage">
    <section class="hero" aria-label="Diagram introduction">
      <div>
        <p class="eyebrow">Animated diagram</p>
        <h1>One clear visual story</h1>
        <p class="subtitle">
          Replace this with one sentence that explains what moves, what changes,
          and why the viewer should care.
        </p>
      </div>
      <button class="motion-toggle" type="button" aria-pressed="false">
        Pause motion
      </button>
    </section>

    <section class="canvas">
      <svg class="diagram" viewBox="0 0 1600 900" role="img" aria-labelledby="diagram-title diagram-desc">
        <title id="diagram-title">Animated concept diagram</title>
        <desc id="diagram-desc">
          A minimal dark-mode animated diagram showing a concept flowing through three stages.
        </desc>

        <defs>
          <marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5"
                  markerWidth="6" markerHeight="6" orient="auto-start-reverse">
            <path d="M 0 0 L 10 5 L 0 10 z" fill="rgba(148, 163, 184, 0.55)" />
          </marker>

          <linearGradient id="edge-gradient" x1="240" y1="0" x2="1360" y2="0" gradientUnits="userSpaceOnUse">
            <stop offset="0%" stop-color="#7dd3fc" stop-opacity="0.22" />
            <stop offset="50%" stop-color="#c084fc" stop-opacity="0.50" />
            <stop offset="100%" stop-color="#86efac" stop-opacity="0.22" />
          </linearGradient>
        </defs>

        <g class="grid" aria-hidden="true">
          <line x1="160" y1="160" x2="1440" y2="160" />
          <line x1="160" y1="450" x2="1440" y2="450" />
          <line x1="160" y1="740" x2="1440" y2="740" />
          <line x1="320" y1="120" x2="320" y2="780" />
          <line x1="800" y1="120" x2="800" y2="780" />
          <line x1="1280" y1="120" x2="1280" y2="780" />
        </g>

        <path class="edge reveal" pathLength="1"
              marker-end="url(#arrow)"
              d="M 410 450 C 545 325, 690 325, 800 450 S 1055 575, 1190 450" />
        <path class="edge" stroke="url(#edge-gradient)" opacity="0.55"
              d="M 320 450 C 545 325, 690 325, 800 450 S 1055 575, 1280 450" />

        <g class="node" transform="translate(320 450)" style="--i: 0">
          <rect class="node-shell" x="-88" y="-40" width="176" height="80" rx="18" />
          <text class="node-title" x="0" y="-5" text-anchor="middle">Input</text>
          <text class="node-caption" x="0" y="18" text-anchor="middle">what starts it</text>
        </g>

        <g class="node active" transform="translate(800 450)" style="--i: 1">
          <rect class="node-shell" x="-92" y="-42" width="184" height="84" rx="20" />
          <text class="node-title" x="0" y="-5" text-anchor="middle">Mechanism</text>
          <text class="node-caption" x="0" y="18" text-anchor="middle">what changes it</text>
        </g>

        <g class="node" transform="translate(1280 450)" style="--i: 2">
          <rect class="node-shell" x="-88" y="-40" width="176" height="80" rx="18" />
          <text class="node-title" x="0" y="-5" text-anchor="middle">Output</text>
          <text class="node-caption" x="0" y="18" text-anchor="middle">what you get</text>
        </g>

        <g class="badge" transform="translate(800 150)">
          <rect x="-92" y="-17" width="184" height="34" rx="17" />
          <text x="0" y="5" text-anchor="middle">cause → effect</text>
        </g>

        <circle class="packet" r="5" cx="0" cy="0" />
        <circle class="packet two" r="4" cx="0" cy="0" />
        <circle class="packet three" r="3.5" cx="0" cy="0" />
      </svg>
    </section>
  </main>

  <script>
    const button = document.querySelector(".motion-toggle");
    const animated = document.querySelectorAll(".diagram *");

    button?.addEventListener("click", () => {
      const paused = document.documentElement.classList.toggle("motion-paused");
      button.textContent = paused ? "Resume motion" : "Pause motion";
      button.setAttribute("aria-pressed", String(paused));

      animated.forEach((element) => {
        element.style.animationPlayState = paused ? "paused" : "running";
      });
    });
  </script>
</body>
</html>
```

---

## Content patterns by topic

### Software architecture

Good default:

- Layered stack or hub-and-spoke.
- Cards: Client, API, Queue, Worker, Database, Observability.
- Motion: request packet, async job packet, metrics pulse.
- Use labels like "request", "event", "query", "write", "alert".
- Collapse unimportant infrastructure into one "Platform" or "Infra" card.

Avoid:

- Full cloud-provider icon maps.
- Every microservice.
- Actual logos unless requested.
- UML-level detail unless requested.

### Code flow

Good default:

- Pipeline, state machine, or sequence.
- Cards: Input, Validate, Transform, Persist, Return.
- Motion: token travels through function blocks.
- Use tiny code-like labels only when useful.

Avoid:

- Large code snippets inside SVG.
- Syntax-highlighted walls of text.
- Too many branches.

### Kubernetes

Good default:

- Layered stack or hub-and-spoke.
- Hub: Control Plane.
- Spokes: User, API Server, Scheduler, Node, Pods.
- Motion: desired state flows to scheduler; pods appear on node; failed pod fades out and replacement fades in.

Avoid:

- Every component name unless the user asks.
- Full cluster architecture clutter.

### RAG / AI systems

Good default:

- Pipeline or hub-and-spoke.
- Cards: User, Retriever, Vector DB, Context, LLM, Answer.
- Motion: query splits into retrieval/context; context merges into LLM.

Avoid:

- Over-explaining embeddings visually unless requested.

### Incident response / on-call

Good default:

- Timeline or hub-and-spoke.
- Cards: Alert, Enrich, Correlate, RCA, Action, Learn.
- Motion: alert packet gathers context from logs/Sentry/Grafana/code and turns into action.

Avoid:

- Fake dashboards.
- Overly optimistic automation claims.

### Cooking / making tea / physical processes

Good default:

- Timeline or pipeline.
- Cards: Water, Heat, Tea, Steep, Pour.
- Motion: steam line, temperature glow, progress rail.

Avoid:

- Realistic illustration.
- Too many ingredients.
- Complex kitchen drawings.

### Abstract concepts

Good default:

- Pick a metaphor:
  - Trust → bridge / feedback loop.
  - Momentum → flywheel.
  - Learning → loop.
  - Risk → branching paths.
  - Latency → queue + bottleneck.
  - Memory → layers / cache.
- Keep it metaphorical but not childish.

---

## Quality checklist

Before finishing, verify:

### Clarity

- [ ] Can the viewer summarize the idea in one sentence after 5 seconds?
- [ ] Is there one obvious focal point?
- [ ] Does the animation show cause/effect?
- [ ] Are labels short and readable?
- [ ] Is the title specific, not generic?

### Minimalism

- [ ] 3-7 primary objects by default.
- [ ] No unnecessary legend.
- [ ] No huge icon set.
- [ ] No duplicated labels.
- [ ] No dense text blocks.

### Aesthetic

- [ ] Dark background feels intentional.
- [ ] Cards, edges, and text align to a grid.
- [ ] Accent color is used sparingly.
- [ ] Glow is subtle.
- [ ] Motion feels calm, not flashy.

### Technical

- [ ] `index.html` opens without internet.
- [ ] SVG has a viewBox and scales responsively.
- [ ] No external dependencies.
- [ ] No console errors.
- [ ] Pause/resume works.
- [ ] Reduced-motion mode is supported.

### Accessibility

- [ ] SVG includes title and description.
- [ ] Important meaning is not color-only.
- [ ] No flashing/strobing.
- [ ] Text contrast is acceptable.
- [ ] Controls are keyboard-accessible buttons.

---

## Common mistakes to avoid

Do not:

- Generate Mermaid as the final output unless the user explicitly asks for Mermaid.
- Use a white background by default.
- Put everything in the diagram.
- Animate every object at once.
- Use rainbow colors.
- Use bounce/stretch easing for serious technical concepts.
- Use rapid flashing.
- Use tiny unreadable text.
- Use external fonts, images, CDNs, or frameworks.
- Use fake product logos or copyrighted brand assets.
- Add complex interactivity when a passive loop is enough.
- Make a generic "AI-looking" particle animation that does not explain the concept.
- Forget reduced-motion support.
- Forget pause/resume.

---

## Advanced mode: explorable diagrams

Use this only when the user asks for an interactive/explorable explanation or when interaction is clearly valuable.

Add:

- One slider or segmented control.
- A visible "what changes" label.
- A clear default state.
- A reset button if the user can change multiple things.

Example controls:

```html
<label class="control">
  Traffic
  <input id="traffic" type="range" min="1" max="10" value="4" />
</label>
```

Rules:

- One control is usually enough.
- The diagram must still be understandable without touching the control.
- Keep controls outside the SVG when possible.
- Do not build a full app.

---

## Scoring rubric

A generated diagram should score at least 14/18.

```text
Clarity       0-3  Is the idea immediately understandable?
Reduction     0-3  Did it remove unnecessary details?
Composition   0-3  Is the layout balanced and readable?
Motion        0-3  Does animation explain, not decorate?
Aesthetic     0-3  Does it feel modern, polished, dark-mode?
Robustness    0-3  Does it work offline, responsive, accessible?
```

If score is below 14, simplify before delivering.

---

## Example generation briefs

### Brief: "Explain Kubernetes simply"

```text
Concept: Kubernetes
Audience: beginner developer
One-sentence story: Kubernetes keeps apps running by comparing desired state with reality and replacing failed pods.
Archetype: hub-and-spoke + small state loop
Objects: User, API Server, Scheduler, Node, Pod, Replacement Pod
Relationships: desired state goes to control plane; scheduler places pod; failed pod is replaced
Motion idea: desired-state packet enters control plane, pod appears on node, one pod fades red/dim, replacement packet creates new pod
What should be understood in 5 seconds: Kubernetes is a control loop that maintains desired state
What can be omitted: etcd, kubelet details, controllers, networking internals
```

### Brief: "Explain making tea"

```text
Concept: making tea
Audience: anyone
One-sentence story: Heat extracts flavor from tea leaves over time, then the liquid is poured out.
Archetype: timeline / pipeline
Objects: Water, Heat, Tea Leaves, Steep, Cup
Relationships: water heats, meets leaves, steeping extracts flavor, cup receives tea
Motion idea: temperature glow rises, tiny flavor particles move from leaves into water, progress rail fills
What should be understood in 5 seconds: tea is extraction over time
What can be omitted: kettle details, exact chemistry, brand details
```

### Brief: "Explain RAG"

```text
Concept: retrieval augmented generation
Audience: software engineer
One-sentence story: RAG improves an LLM answer by retrieving relevant documents and injecting them as context before generation.
Archetype: pipeline with split/merge
Objects: User Query, Retriever, Vector DB, Context, LLM, Answer
Relationships: query goes to retriever, retriever fetches docs, context joins LLM prompt
Motion idea: query token splits into search beam and prompt beam; context packets merge into LLM
What should be understood in 5 seconds: retrieval supplies grounded context to the generator
What can be omitted: chunking, reranking, evals unless requested
```

---

## Reference sources used to design this skill

These are references for the skill designer, not required dependencies for generated diagrams.

- MDN SVG documentation: https://developer.mozilla.org/en-US/docs/Web/SVG
- W3C SVG 2 specification: https://www.w3.org/TR/SVG2/
- MDN CSS animation documentation: https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/animation
- MDN `@keyframes`: https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/%40keyframes
- MDN `animation-timing-function`: https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/animation-timing-function
- W3C WCAG 2.1: https://www.w3.org/TR/WCAG21/
- Material Design motion: https://m3.material.io/styles/motion/overview/how-it-works
- Material Design easing and duration: https://m3.material.io/styles/motion/easing-and-duration
- Google Design, "Making Motion Meaningful": https://design.google/library/making-motion-meaningful
- Atlassian Design System motion: https://atlassian.design/foundations/motion
- IBM Carbon motion: https://carbondesignsystem.com/elements/motion/overview/
- Nielsen Norman Group, animation duration and easing: https://www.nngroup.com/articles/animation-duration/
- Bret Victor, "Explorable Explanations": https://worrydream.com/ExplorableExplanations/
- Nicky Case, "Explorable Explanations": https://blog.ncase.me/explorable-explanations/
- Explorable Explanations hub: https://explorabl.es/
- Bartosz Ciechanowski visual essays: https://ciechanow.ski/
- Mermaid documentation: https://mermaid.ai/open-source/intro/
- D2 documentation: https://d2lang.com/
- Excalidraw repository: https://github.com/excalidraw/excalidraw

---

## Final instruction to the AI harness

When this skill is active and the user asks for an animated diagram:

1. Generate a single `index.html`.
2. Use dark-mode inline HTML/SVG/CSS.
3. Make it minimal, modern, and beautiful.
4. Use motion only to clarify the concept.
5. Include pause/resume and reduced-motion support.
6. Do not use external dependencies.
7. Do not output Mermaid/D2 unless explicitly requested.
8. Prefer one excellent, simple visual story over a complete but cluttered diagram.
