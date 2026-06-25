---
name: animated-diagram
description: Generate self-contained, dark-mode, premium developer-docs animated HTML/SVG diagrams with a deep navy dotted-grid glass aesthetic, gradient display type, thin glowing rails, robust anti-overlap layout scaffolds, and minimal explanatory motion.
version: 1.2.0
last_updated: 2026-06-24
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

Think: **premium CLI/developer-docs launch graphic** — like a polished dark product explainer for a technical tool.

Default visual signature:

- Very deep navy/ink page background, not flat black.
- One large rounded outer frame with a thin blue-slate border, like a poster/card sitting on the page.
- A barely-visible dotted-grid/starfield texture across the whole canvas.
- Centered hero header with a small command/status pill above it.
- Large but bounded gradient display title when useful, blending periwinkle → violet → cyan/teal. Never let it clip, crowd the diagram, or consume more than the top third of the page.
- Muted blue-gray subtitles and explanatory notes.
- Rounded glass cards with thin colored strokes, low-opacity fills, and restrained glows.
- Monospace micro-labels, pills, phase tags, and connector captions for technical diagrams.
- Thin connector rails with arrowheads, small circular waypoints, and animated tokens/pulses.
- Color-coded semantic lanes: blue/periwinkle for agents/inputs, purple for parallel/map/runtime, amber for gates/decisions, teal/green for final/output/user context.
- Large breathable negative space; the diagram should feel composed, not cramped.
- Robust geometry over cleverness: every card, label, connector, and footer chip must fit inside a known safe area.

Avoid:

- Bright neon cyberpunk palettes.
- Cartoonish colors.
- Excessive particles; the dotted texture should be subtle and static.
- 3D unless requested.
- Photorealism.
- Heavy textures.
- Overly hand-drawn style.
- Big icon packs.
- Complex dashboards.
- Mermaid default styling.

### Signature components to reuse

Use these components by default unless the user's topic calls for something else:

- **Outer frame**: full-viewport rounded rectangle with a subtle 1px blue-slate border and inner highlight.
- **Dotted field**: CSS radial dot grid at very low opacity; it gives depth without becoming a background pattern that competes with the diagram.
- **Command/status pill**: small centered pill above the title, with a teal status dot and monospace text such as `request · lifecycle`, `phase · training`, or `query · retrieval`.
- **Gradient hero wordmark**: for big concepts/tools, use one huge title word with a blue → violet → teal gradient. For dense diagrams, use a smaller version so the diagram remains primary.
- **Dashed boundary boxes**: use dashed blue/purple rounded containers to show an isolated runtime, cluster, subprocess, or system boundary.
- **Semantic glass cards**: cards should have low-opacity fills and colored borders; avoid solid filled boxes.
- **Right-side result/context panel**: when explaining “only the final output returns” or “user context stays clean,” place the final result in a green glass panel on the right.
- **Bottom phase chips**: for taxonomies or multi-phase systems, place small rounded chips along the bottom instead of a large legend.

### Theme tokens

Use these as the default starting point:

```css
:root {
  color-scheme: dark;

  --bg-0: #050815;
  --bg-1: #090d1b;
  --bg-2: #0d1224;
  --frame: #090d1a;
  --panel: rgba(13, 20, 38, 0.74);
  --panel-strong: rgba(17, 24, 46, 0.92);
  --panel-green: rgba(7, 45, 36, 0.58);
  --panel-purple: rgba(30, 22, 58, 0.66);
  --panel-amber: rgba(44, 31, 15, 0.62);

  --stroke: rgba(110, 132, 190, 0.28);
  --stroke-strong: rgba(139, 165, 230, 0.48);
  --stroke-purple: rgba(169, 139, 255, 0.48);
  --stroke-amber: rgba(245, 183, 89, 0.54);
  --stroke-green: rgba(57, 211, 159, 0.56);

  --text: #eef3ff;
  --muted: #aab7d4;
  --faint: #667397;

  --blue: #86a8ff;
  --periwinkle: #9bbcff;
  --purple: #a78bfa;
  --violet: #c4a3ff;
  --cyan: #70d6e8;
  --teal: #47e0b2;
  --amber: #ffc464;
  --danger: #fb7185;

  --accent: var(--teal);
  --accent-2: var(--purple);
  --accent-3: var(--blue);
  --warn: var(--amber);

  --radius-sm: 12px;
  --radius-md: 18px;
  --radius-lg: 30px;
  --radius-xl: 44px;

  --shadow-soft: 0 24px 90px rgba(0, 0, 0, 0.42);
  --glow-blue: 0 0 30px rgba(134, 168, 255, 0.22);
  --glow-purple: 0 0 30px rgba(167, 139, 250, 0.22);
  --glow-green: 0 0 32px rgba(71, 224, 178, 0.25);

  --mono: "SFMono-Regular", "Cascadia Code", "Liberation Mono", Menlo, Consolas, monospace;

  --ease-out: cubic-bezier(0, 0.4, 0, 1);
  --ease-standard: cubic-bezier(0.2, 0, 0.38, 0.9);
  --ease-soft: cubic-bezier(0.16, 1, 0.3, 1);

  --dur-fast: 160ms;
  --dur-med: 360ms;
  --dur-slow: 720ms;
}
```

### Typography

Use system sans for titles and system monospace for diagram labels:

```css
body {
  font-family:
    Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
    "Segoe UI", sans-serif;
}

.mono,
.badge,
.edge-label,
.node-caption {
  font-family: var(--mono);
}
```

Do not import Inter or any remote font. The browser will fall back to system fonts.

Recommended sizes:

```css
.hero-title {
  font-size: clamp(3rem, 7vw, 6.8rem);
  line-height: 0.96;
  letter-spacing: -0.06em;
  font-weight: 850;
  text-wrap: balance;
  background: linear-gradient(90deg, #8fb4ff 0%, #b79cff 43%, #59e0b7 100%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.hero-subtitle {
  font-size: clamp(1rem, 1.5vw, 1.55rem);
  line-height: 1.45;
  color: #c5cee3;
}

.node-label {
  font-size: 18px;
  font-weight: 800;
  letter-spacing: -0.02em;
}

.node-caption {
  font-size: 13px;
  letter-spacing: 0.08em;
  color: var(--muted);
}

.edge-label {
  font-family: var(--mono);
  font-size: 13px;
  letter-spacing: 0.14em;
  color: var(--teal);
}
```

For smaller explanatory diagrams, scale the hero down; keep the same gradient and tight tracking. Prefer a readable title that fits over an enormous title that steals space from the diagram.

### Layout

Default SVG viewBox:

```html
<svg viewBox="0 0 1800 980" role="img" aria-labelledby="diagram-title diagram-desc">
```

Use a poster-like full-page frame. The page should usually contain one `.frame` or `.canvas` with `width: min(2000px, calc(100vw - 4px))`, `min-height: calc(100vh - 4px)`, a 36-44px corner radius, and a thin blue-slate border. Keep the hero centered in the top third, then place the diagram below it with generous whitespace.

Use the viewport generously. Do **not** artificially cap the diagram at 1120px wide for normal desktop screens; the stage should usually be between 1800px and 2000px wide on large displays, and the SVG should take most of the visible page. Use a 16px or 24px spacing rhythm. Keep key objects away from edges.

### Robust layout contract

This skill should favor layouts that are hard for an LLM to break. Before writing SVG, create a tiny layout table for every visible object:

```text
id | role | x | y | w | h | anchors | notes
```

For the default `1800x980` SVG, use these safe zones:

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

- **No clipped objects**: do not intentionally crop cards, labels, title text, arrows, chips, glows, or panels. Nothing important may start outside the hard safe area.
- **No negative-position cards**: avoid `translate(-...)`, negative `x/y`, or large center-based cards unless you have checked `center - width/2 >= 120` and `center + width/2 <= 1680`.
- **Prefer top-left geometry** for cards: `<rect x="240" y="420" width="220" height="92" rx="18">` is safer than a translated group with negative rect coordinates.
- **Hero must fit first**: if the title wraps to two lines, reduce `font-size`/`letter-spacing` until it fits the hero zone. Do not let a display title touch the top border.
- **Diagram must have visible nodes**: never output floating arrows without the main cards/nodes they connect.
- **Footer chips are optional**: omit them if they would be clipped or distract from the core diagram.

Space and anti-overlap rules:

- Expand the canvas/viewBox before shrinking text or allowing clutter.
- For dense diagrams, upgrade to `1800x1100`, `2000x1200`, or a taller full-page SVG if needed.
- Prefer a slightly scrollable full-page diagram over tiny labels or crowded cards.
- Keep at least 32px between unrelated objects, 48px between cards and connector labels, and 14-18px internal padding around text.
- Route connectors around cards; never let labels sit under boxes, edges, or arrowheads.
- If a label needs more than 1-4 words, wrap it inside a wider card or move details into a subtitle/note outside the SVG.
- Before finalizing, scan the SVG for text/card overlaps and fix them by increasing spacing, moving lanes, or reducing object count.

---

## Safe scaffolds for simple diagrams

When the request is simple, do **not** invent a complex freeform composition. Pick one of these stable scaffolds and customize only labels, colors, and 1-2 motion tokens.

### Scaffold A: centered 3-step pipeline

Use for most simple “A becomes B becomes C” concepts.

```text
Title/subtitle in hero zone

[Card A] ─────────▶ [Card B] ─────────▶ [Card C]
  x=260 y=470       x=790 y=470       x=1320 y=470
  w=240 h=96        w=240 h=96        w=240 h=96
```

Rules: straight or gently curved connectors only; no side panels; no footer chips unless requested.

### Scaffold B: left inputs → center processor → right result panel

Use when one config/source fans into outputs or context.

```text
Inputs stack        Processor boundary          Result panel
x=220 y=390         x=680 y=350 w=520 h=360      x=1320 y=390 w=280 h=240
```

Rules: keep the input stack fully inside the left lane; never crop it off the left edge. The result panel should be green/teal.

### Scaffold C: two-column before/after

Use for simplification, refactors, migrations, transformations.

```text
Before panel                         After panel
x=220 y=380 w=560 h=360              x=1020 y=380 w=560 h=360
```

Rules: one transform arrow between panels; avoid diagonal spaghetti.

### Scaffold D: state row with one branch

Use for job/order/status lifecycles.

```text
Queued → Running → Success
            ↓
          Retry/Failed
```

Rules: keep all states in one bounded rectangle; at most one retry branch.

If none of these fit, use the archetypes below, but still create the layout table before coding.

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
Archetype or safe scaffold:
Objects:
Relationships:
Layout table: id | role | x | y | w | h | anchors | notes
Motion idea:
What should be understood in 5 seconds:
What can be omitted:
```

Then generate the file. The layout table is not optional for diagrams with 2+ visible objects; it prevents clipped cards, orphan arrows, and accidental overlaps.

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

5. **Choose the simplest safe scaffold**
   - For simple concepts, use Scaffold A/B/C/D instead of freeform SVG.
   - Only use a custom composition when a safe scaffold clearly cannot explain the concept.

6. **Layout numerically before coding**
   - Write the object table mentally first: `id | x | y | w | h`.
   - Verify all objects are inside `x=120..1680, y=80..900` for `1800x980`.
   - Verify hero text stays inside `y=60..260` and diagram objects stay mostly inside `y=330..780`.
   - Align cards to a grid.
   - Keep connector crossings near zero.
   - Prefer horizontal/vertical/elbow connectors over arbitrary long curves.

7. **Animate**
   - Use no more than 2-3 simultaneous motion ideas.
   - Prefer packet travel, highlight, reveal, progress, orbit, or pulse.
   - Use staggered delays to guide attention.

8. **Add microcopy**
   - Title: what the diagram explains.
   - Subtitle: one sentence.
   - Labels: short nouns/verbs.
   - Optional note: one tiny explanatory note.

9. **Add controls**
   - Always include pause/resume for looping animations.
   - Include step buttons only if the diagram is a multi-step lesson.

10. **Run visual QA and fix before delivering**
   - Check visual balance.
   - Check reduced motion.
   - Check that the diagram uses most of the available viewport on desktop instead of floating in a small 1120px island.
   - Check that the diagram works at 800px wide and 1600px+ wide.
   - Check that title text is not clipped, overly large, or touching the border.
   - Check that no card/panel/chip is partially offscreen.
   - Check that every connector points to visible cards/nodes; no orphan arrows.
   - Check that labels do not overlap cards, connectors, arrowheads, badges, or other text.
   - Check that the animation tells the story even without reading every label.
   - If browser/screenshot tools are available, render `index.html` and inspect the screenshot. If anything is clipped or oddly sparse, fix the file before returning it.

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

Use colored variants for semantic lanes: default blue, `.purple` for runtime/parallel/map, `.amber` for gates/decisions, `.green` for final/output/user context.

```html
<g class="node purple" transform="translate(240 340)" style="--i: 0">
  <rect class="node-shell" x="-92" y="-42" width="184" height="84" rx="18" />
  <circle class="node-dot" cx="-58" cy="-10" r="6" />
  <text class="node-title" x="-36" y="-3">Input</text>
  <text class="node-caption" x="-58" y="24">raw · signal</text>
</g>
```

```css
.node-shell {
  fill: rgba(15, 23, 42, 0.72);
  stroke: rgba(116, 142, 212, 0.44);
  stroke-width: 1.4;
}
.node.purple .node-shell { fill: rgba(30, 22, 58, 0.68); stroke: rgba(167, 139, 250, 0.55); }
.node.green .node-shell  { fill: rgba(7, 45, 36, 0.58); stroke: rgba(57, 211, 159, 0.62); }
.node.amber .node-shell  { fill: rgba(44, 31, 15, 0.62); stroke: rgba(245, 183, 89, 0.56); }
.node-dot { fill: currentColor; }
.node-title { fill: var(--text); font-size: 18px; font-weight: 820; letter-spacing: -0.02em; }
.node-caption { fill: var(--muted); font: 600 12px var(--mono); letter-spacing: 0.08em; }
```

Prefer left-aligned labels inside cards with a small colored dot, especially for technical flow diagrams. Center labels only for symmetric/simple diagrams.

### Connector

```html
<path class="edge reveal" pathLength="1" d="M 322 340 C 400 340, 430 340, 508 340" />
<text class="edge-label" x="416" y="318" text-anchor="middle">only the result</text>
```

```css
.edge {
  fill: none;
  stroke: rgba(116, 142, 212, 0.42);
  stroke-width: 3;
  stroke-linecap: round;
}
.edge-label {
  fill: var(--teal);
  font: 600 13px var(--mono);
  letter-spacing: 0.14em;
}
```

Keep connector labels tiny and away from paths; use small waypoint circles on long rails when it clarifies movement.

### Arrow marker

```html
<defs>
  <marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5"
          markerWidth="6" markerHeight="6" orient="auto-start-reverse">
    <path d="M 0 0 L 10 5 L 0 10 z" fill="rgba(71, 224, 178, 0.72)" />
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
      --bg-0: #050815;
      --bg-1: #090d1b;
      --frame: #090d1a;
      --panel: rgba(13, 20, 38, 0.74);
      --panel-strong: rgba(17, 24, 46, 0.92);
      --stroke: rgba(110, 132, 190, 0.30);
      --stroke-strong: rgba(139, 165, 230, 0.52);
      --text: #eef3ff;
      --muted: #aab7d4;
      --faint: #667397;
      --blue: #86a8ff;
      --purple: #a78bfa;
      --cyan: #70d6e8;
      --teal: #47e0b2;
      --amber: #ffc464;
      --accent: var(--teal);
      --accent-2: var(--purple);
      --accent-3: var(--blue);
      --radius-lg: 30px;
      --radius-xl: 44px;
      --shadow-soft: 0 24px 90px rgba(0, 0, 0, 0.42);
      --glow-green: 0 0 32px rgba(71, 224, 178, 0.24);
      --mono: "SFMono-Regular", "Cascadia Code", "Liberation Mono", Menlo, Consolas, monospace;
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
      background: #030611;
      color: var(--text);
      font-family:
        Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
        "Segoe UI", sans-serif;
    }

    .stage {
      position: relative;
      width: min(2000px, calc(100vw - 4px));
      min-height: calc(100vh - 4px);
      overflow: hidden;
      display: grid;
      grid-template-rows: auto minmax(0, 1fr);
      align-content: center;
      padding: clamp(28px, 3vw, 58px);
      border: 1px solid rgba(92, 116, 180, 0.34);
      border-radius: var(--radius-xl);
      background:
        radial-gradient(circle at 50% 20%, rgba(135, 165, 255, 0.10), transparent 30%),
        radial-gradient(circle at 82% 35%, rgba(71, 224, 178, 0.08), transparent 28%),
        radial-gradient(circle at 18% 70%, rgba(167, 139, 250, 0.08), transparent 30%),
        radial-gradient(circle, rgba(110, 132, 190, 0.14) 0 1.3px, transparent 1.4px) 0 0 / 50px 50px,
        linear-gradient(180deg, var(--bg-1), var(--bg-0));
      box-shadow: var(--shadow-soft), inset 0 1px 0 rgba(255, 255, 255, 0.035);
    }

    .hero {
      display: grid;
      justify-items: center;
      gap: 14px;
      text-align: center;
      margin: 0 0 clamp(18px, 2.4vh, 34px);
    }

    .eyebrow {
      display: inline-flex;
      align-items: center;
      gap: 14px;
      margin: 0 0 18px;
      padding: 12px 26px;
      border: 1px solid rgba(116, 142, 212, 0.42);
      border-radius: 999px;
      background: rgba(16, 24, 48, 0.72);
      color: var(--muted);
      font-family: var(--mono);
      font-size: clamp(0.82rem, 1.15vw, 1.32rem);
      letter-spacing: 0.12em;
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.035);
    }

    .eyebrow::before {
      content: "";
      width: 12px;
      height: 12px;
      border-radius: 999px;
      background: var(--teal);
      box-shadow: 0 0 18px rgba(71, 224, 178, 0.48);
    }

    h1 {
      margin: 0;
      max-width: 1120px;
      font-size: clamp(3rem, 7vw, 6.8rem);
      line-height: 0.96;
      font-weight: 850;
      letter-spacing: -0.06em;
      text-wrap: balance;
      background: linear-gradient(90deg, #8fb4ff 0%, #b79cff 43%, #59e0b7 100%);
      -webkit-background-clip: text;
      background-clip: text;
      color: transparent;
    }

    .subtitle {
      margin: 14px auto 0;
      max-width: 980px;
      color: #c5cee3;
      font-size: clamp(1rem, 1.5vw, 1.55rem);
      line-height: 1.45;
      font-weight: 520;
    }

    .motion-toggle {
      position: absolute;
      right: clamp(26px, 3vw, 54px);
      top: clamp(24px, 3vw, 48px);
      appearance: none;
      border: 1px solid var(--stroke);
      border-radius: 999px;
      background: rgba(13, 20, 38, 0.72);
      color: var(--muted);
      padding: 10px 14px;
      font: inherit;
      font-size: 0.85rem;
      cursor: pointer;
      box-shadow: 0 14px 50px rgba(0, 0, 0, 0.30);
    }

    .motion-toggle:hover {
      border-color: var(--stroke-strong);
      color: var(--text);
      background: rgba(25, 36, 68, 0.76);
    }

    .canvas {
      position: relative;
      overflow: visible;
      border: 0;
      background: transparent;
    }

    svg {
      display: block;
      width: 100%;
      height: auto;
    }

    .grid {
      opacity: 0.12;
    }

    .grid line {
      stroke: rgba(110, 132, 190, 0.20);
      stroke-width: 1;
      stroke-dasharray: 10 16;
    }

    .edge {
      fill: none;
      stroke: rgba(116, 142, 212, 0.42);
      stroke-width: 3;
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
      fill: rgba(15, 23, 42, 0.72);
      stroke: rgba(116, 142, 212, 0.44);
      stroke-width: 1.4;
    }

    .node.purple .node-shell {
      fill: rgba(30, 22, 58, 0.68);
      stroke: rgba(167, 139, 250, 0.55);
    }

    .node.green .node-shell {
      fill: rgba(7, 45, 36, 0.58);
      stroke: rgba(57, 211, 159, 0.62);
      filter: drop-shadow(0 0 18px rgba(71, 224, 178, 0.18));
    }

    .node.active .node-shell {
      animation: active-pulse 2600ms var(--ease-soft) infinite;
      animation-delay: 1000ms;
    }

    .node-title {
      fill: var(--text);
      font-size: 20px;
      font-weight: 820;
      letter-spacing: -0.02em;
    }

    .node-caption {
      fill: var(--muted);
      font-family: var(--mono);
      font-size: 13px;
      font-weight: 600;
      letter-spacing: 0.08em;
    }

    .packet {
      fill: var(--accent);
      opacity: 0;
      offset-path: path("M 360 520 C 620 380, 760 380, 900 520 S 1180 660, 1440 520");
      offset-rotate: 0deg;
      animation: travel 4400ms var(--ease-standard) infinite;
      filter: drop-shadow(0 0 14px rgba(71, 224, 178, 0.62));
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
      fill: rgba(16, 24, 48, 0.76);
      stroke: rgba(116, 142, 212, 0.42);
    }

    .badge text {
      fill: var(--muted);
      font-family: var(--mono);
      font-size: 13px;
      font-weight: 700;
      letter-spacing: 0.14em;
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
        stroke: rgba(116, 142, 212, 0.34);
        filter: drop-shadow(0 0 0 rgba(71, 224, 178, 0));
      }
      50% {
        stroke: rgba(71, 224, 178, 0.78);
        filter: drop-shadow(0 0 22px rgba(71, 224, 178, 0.24));
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
        text-align: left;
        justify-items: start;
        padding-top: 54px;
      }

      .motion-toggle {
        right: 18px;
        top: 18px;
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
        <p class="eyebrow">diagram · animated explainer</p>
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
      <svg class="diagram" viewBox="0 0 1800 980" role="img" aria-labelledby="diagram-title diagram-desc">
        <title id="diagram-title">Animated concept diagram</title>
        <desc id="diagram-desc">
          A minimal dark-mode animated diagram showing a concept flowing through three stages.
        </desc>

        <defs>
          <marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5"
                  markerWidth="6" markerHeight="6" orient="auto-start-reverse">
            <path d="M 0 0 L 10 5 L 0 10 z" fill="rgba(71, 224, 178, 0.72)" />
          </marker>

          <linearGradient id="edge-gradient" x1="240" y1="0" x2="1480" y2="0" gradientUnits="userSpaceOnUse">
            <stop offset="0%" stop-color="#86a8ff" stop-opacity="0.28" />
            <stop offset="50%" stop-color="#a78bfa" stop-opacity="0.52" />
            <stop offset="100%" stop-color="#47e0b2" stop-opacity="0.68" />
          </linearGradient>
        </defs>

        <g class="grid" aria-hidden="true">
          <line x1="160" y1="190" x2="1640" y2="190" />
          <line x1="160" y1="520" x2="1640" y2="520" />
          <line x1="160" y1="820" x2="1640" y2="820" />
          <line x1="360" y1="150" x2="360" y2="850" />
          <line x1="900" y1="150" x2="900" y2="850" />
          <line x1="1440" y1="150" x2="1440" y2="850" />
        </g>

        <path class="edge reveal" pathLength="1"
              marker-end="url(#arrow)"
              d="M 460 520 C 620 380, 760 380, 900 520 S 1180 660, 1340 520" />
        <path class="edge" stroke="url(#edge-gradient)" opacity="0.62"
              d="M 360 520 C 620 380, 760 380, 900 520 S 1180 660, 1440 520" />

        <g class="node" transform="translate(360 520)" style="--i: 0">
          <rect class="node-shell" x="-88" y="-40" width="176" height="80" rx="18" />
          <text class="node-title" x="0" y="-5" text-anchor="middle">Input</text>
          <text class="node-caption" x="0" y="18" text-anchor="middle">what starts it</text>
        </g>

        <g class="node active purple" transform="translate(900 520)" style="--i: 1">
          <rect class="node-shell" x="-92" y="-42" width="184" height="84" rx="20" />
          <text class="node-title" x="0" y="-5" text-anchor="middle">Mechanism</text>
          <text class="node-caption" x="0" y="18" text-anchor="middle">what changes it</text>
        </g>

        <g class="node green" transform="translate(1440 520)" style="--i: 2">
          <rect class="node-shell" x="-88" y="-40" width="176" height="80" rx="18" />
          <text class="node-title" x="0" y="-5" text-anchor="middle">Output</text>
          <text class="node-caption" x="0" y="18" text-anchor="middle">what you get</text>
        </g>

        <g class="badge" transform="translate(900 170)">
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

- [ ] Deep navy background and dotted field feel intentional, not noisy.
- [ ] Outer frame, hero, cards, edges, and text align to a clear grid.
- [ ] Gradient title/accents use the blue → violet → teal palette sparingly.
- [ ] Glass cards have thin semantic strokes and subtle glow, not neon overload.
- [ ] Motion feels calm, product-quality, and explanatory.

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
- Use rainbow colors instead of the blue/purple/teal/amber semantic palette.
- Use bright neon glows that overpower the muted glass look.
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
