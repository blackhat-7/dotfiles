---
name: animated-diagram
description: Create a simple, beautiful, self-contained animated HTML + SVG explainer for a concept. Use when the user asks for animated diagrams, visual explainers, concept explainers, mini interactive HTML/SVG illustrations, or a single-file index.html with SVG/CSS animation.
---

# HTML SVG Concept Explainer Skill

Create a simple, beautiful, self-contained animated HTML + SVG explainer for any concept.

The final output MUST be a single file named `index.html` that can be opened directly in a browser. No build step. No external dependencies. No React. No D3. No Mermaid. No CDN. No external images. No external fonts.

## Goal

Explain a concept visually to a specific audience using:

- one clear mental model
- one animated SVG diagram
- short labels
- progressive step-by-step explanation
- simple CSS animations
- optional tiny JavaScript only when needed for play/pause, step controls, or simple hover/click details

The result should feel like a polished mini explainer, not a generic architecture diagram.

## Default behavior

Unless the user says otherwise:

- Audience: beginner
- Depth: simple
- Style: clean dark mode
- Animation: enabled
- Interactivity: minimal
- Output: `index.html`
- Format: inline HTML + CSS + SVG
- JavaScript: avoid unless useful

## Hard requirements

Always create exactly one browser-openable file:

```text
index.html
```

The file must contain:

1. Complete HTML document
2. Inline CSS
3. Inline SVG
4. Optional inline JavaScript
5. No external network requests
6. A visible title
7. A one-sentence subtitle
8. A short explanation below the diagram
9. A legend if colors have meaning
10. Responsive layout
11. Reduced-motion fallback
12. Accessible SVG title and description

Do not create multiple files unless the user explicitly asks.

## File output rule

If running inside a coding agent, actually create the file.

If unable to create files, output the full contents of `index.html`.

Final response should be short:

```text
Created `index.html`.

Open it in your browser.
```

## Design philosophy

Prioritize clarity over completeness.

The best diagram is the one where a beginner understands the core idea in 30 seconds.

Use animation to explain causality, flow, state, or transformation. Do not use animation as decoration.

## Before generating

Silently decide:

1. What is the one-sentence explanation?
2. Who is the audience?
3. What is the best visual metaphor?
4. What is the best diagram pattern?
5. What are the 4–7 main objects?
6. What is the animation story?
7. What does each color mean?
8. What are the 3–5 explanation cards below the diagram?

Do not expose this reasoning unless asked.

## Visual metaphor rules

Pick one strong metaphor and stick to it.

Examples:

- Kubernetes: control room, factory manager, airport control tower
- Docker: shipping container, portable lunchbox
- RAG: librarian with notes
- Database index: book index, library catalog
- Message queue: conveyor belt, post office
- Load balancer: traffic police, receptionist
- OAuth: valet key, bouncer with wristbands
- CI/CD: assembly line
- DNS: phonebook, address lookup
- Cache: nearby shelf, shortcut memory
- Git: timeline of snapshots, branching tree
- Raft consensus: village voting

Do not mix metaphors unless absolutely necessary.

## Diagram patterns

Choose exactly one primary pattern.

### 1. Flow pattern

Use for request flows, pipelines, scheduling, networking, CI/CD, RAG, auth, and lifecycle explanations.

Shape:

```text
Actor -> Entry -> Decision -> Worker -> Result
```

Animation:

- moving packet/dot
- active step highlight
- changing caption

### 2. Layer pattern

Use for stacks, architecture, networking, operating systems, and cloud platforms.

Shape:

```text
User layer
API/interface layer
Logic layer
Runtime layer
Infrastructure layer
```

Animation:

- layers fade in
- optional hover/click details

### 3. State machine pattern

Use for jobs, retries, consensus, order processing, failure handling, auth state, and schedulers.

Shape:

```text
Pending -> Running -> Success
              |
              v
            Failed -> Retry
```

Animation:

- token moves between states
- failure path is visibly different

### 4. Comparison pattern

Use to explain why a tool exists.

Shape:

```text
Before: manual / fragile / slow
After: automated / resilient / observable
```

Animation:

- before side shows friction
- after side simplifies or repairs it

### 5. System map pattern

Use for distributed systems.

Shape:

```text
Control center
Workers
Network
Storage
Users
Monitoring
```

Animation:

- messages move between components
- health/status changes are highlighted

## Simplicity rules

For beginner explanations:

- Use 4–7 major visual objects
- Use short labels, ideally 1–4 words
- Avoid paragraphs inside the SVG
- Avoid more than 2 nested levels
- Avoid full production-level completeness
- Show the main idea first, details second
- Prefer one strong visual story over many small facts

## Color language

Use consistent color meaning:

- Blue: control, decisions, APIs
- Green: running, healthy, success
- Yellow: routing, service, interface, attention
- Red: error, failure, retry
- Gray: infrastructure, background, inactive parts
- Purple: data, memory, storage

Use CSS variables:

```css
:root {
  --bg: #0f172a;
  --panel: #111827;
  --panel-2: #1f2937;
  --text: #e5e7eb;
  --muted: #cbd5e1;
  --line: #94a3b8;
  --blue: #60a5fa;
  --green: #34d399;
  --yellow: #fbbf24;
  --red: #f87171;
  --purple: #a78bfa;
}
```

## Animation rules

Animation must teach causality.

Good animations:

- packet moving through a system
- node lighting up when active
- pod/container appearing when scheduled
- retry path blinking after failure
- layer fading in when introduced
- queue item moving from waiting to processing
- desired state vs actual state converging
- data moving from source to processor to result

Bad animations:

- random bouncing
- spinning icons with no meaning
- too many simultaneous movements
- decorative particles
- complex motion that distracts from the concept

Prefer CSS keyframes.

Use loop durations around 12–30 seconds for animated explainers.

Every animation should have a matching caption, label, or visible meaning.

## Reduced motion requirement

Every file must include this CSS:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.001ms !important;
    animation-iteration-count: 1 !important;
    scroll-behavior: auto !important;
  }
}
```

If using JavaScript animation, also respect:

```js
const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
```

## Accessibility requirements

The main SVG must include:

```html
<svg role="img" aria-labelledby="diagram-title diagram-desc" viewBox="0 0 1200 700">
  <title id="diagram-title">Short diagram title</title>
  <desc id="diagram-desc">One sentence describing what the diagram explains.</desc>
</svg>
```

Use readable text sizes:

- Main labels: 16–22px
- Secondary labels: 12–15px
- Captions: 14–18px

Do not rely on color alone. Use labels, shapes, or icons too.

## Required HTML structure

Use this structure:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title><!-- concept title --></title>
  <style>
    /* all CSS here */
  </style>
</head>
<body>
  <main class="wrap">
    <header>
      <h1><!-- title --></h1>
      <p class="subtitle"><!-- one sentence summary --></p>
    </header>

    <section class="diagram-card">
      <svg role="img" aria-labelledby="diagram-title diagram-desc" viewBox="0 0 1200 700">
        <title id="diagram-title"><!-- accessible title --></title>
        <desc id="diagram-desc"><!-- accessible description --></desc>

        <!-- defs, paths, boxes, labels, animated elements -->
      </svg>
    </section>

    <section class="explanation">
      <!-- short explanation cards -->
    </section>
  </main>

  <script>
    /* optional tiny JS only if required */
  </script>
</body>
</html>
```

## Required CSS baseline

Use this baseline and adapt it:

```css
:root {
  --bg: #0f172a;
  --panel: #111827;
  --panel-2: #1f2937;
  --text: #e5e7eb;
  --muted: #cbd5e1;
  --line: #94a3b8;
  --blue: #60a5fa;
  --green: #34d399;
  --yellow: #fbbf24;
  --red: #f87171;
  --purple: #a78bfa;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  min-height: 100vh;
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  background:
    radial-gradient(circle at top, rgba(37, 99, 235, 0.32), transparent 38%),
    var(--bg);
  color: var(--text);
  display: grid;
  place-items: center;
  padding: 24px;
}

.wrap {
  width: min(1180px, 100%);
}

header {
  margin-bottom: 16px;
}

h1 {
  margin: 0 0 8px;
  font-size: clamp(28px, 5vw, 52px);
  letter-spacing: -0.05em;
}

.subtitle {
  margin: 0;
  color: var(--muted);
  font-size: 16px;
  line-height: 1.5;
}

.diagram-card {
  border: 1px solid rgba(148, 163, 184, 0.22);
  background: linear-gradient(180deg, rgba(30, 41, 59, 0.92), rgba(15, 23, 42, 0.96));
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 24px 80px rgba(0, 0, 0, 0.35);
}

svg {
  display: block;
  width: 100%;
  height: auto;
}

.box {
  fill: rgba(17, 24, 39, 0.94);
  stroke: rgba(148, 163, 184, 0.45);
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
  stroke: rgba(148, 163, 184, 0.55);
  stroke-width: 3;
  stroke-linecap: round;
  stroke-dasharray: 8 10;
}

.packet {
  filter: drop-shadow(0 0 10px rgba(96, 165, 250, 0.9));
}

.explanation {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  margin-top: 14px;
}

.note {
  border: 1px solid rgba(148, 163, 184, 0.18);
  background: rgba(15, 23, 42, 0.75);
  border-radius: 16px;
  padding: 14px;
}

.note b {
  display: block;
  margin-bottom: 4px;
}

.note span {
  color: var(--muted);
  font-size: 14px;
  line-height: 1.45;
}

@media (max-width: 780px) {
  body {
    padding: 14px;
  }

  .explanation {
    grid-template-columns: 1fr;
  }
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.001ms !important;
    animation-iteration-count: 1 !important;
    scroll-behavior: auto !important;
  }
}
```

## Recommended SVG conventions

Use simple reusable shapes.

Rounded component box:

```html
<rect class="box" x="80" y="120" width="180" height="110" rx="18" />
<text class="label" x="120" y="170">Component</text>
<text class="small" x="120" y="198">short role</text>
```

Dashed flow line:

```html
<path class="line" d="M260 175 H480" />
```

Animated packet:

```html
<circle class="packet packet-1" r="10" cx="0" cy="0" />
```

Example packet animation:

```css
.packet-1 {
  fill: var(--blue);
  animation: movePacket 12s linear infinite;
}

@keyframes movePacket {
  0%   { transform: translate(120px, 180px); opacity: 0; }
  8%   { opacity: 1; }
  25%  { transform: translate(320px, 180px); opacity: 1; }
  45%  { transform: translate(520px, 180px); opacity: 1; }
  65%  { transform: translate(720px, 180px); opacity: 1; }
  85%  { transform: translate(920px, 180px); opacity: 1; }
  100% { transform: translate(980px, 180px); opacity: 0; }
}
```

Step caption pattern:

```html
<g class="step step-1">
  <rect x="40" y="620" width="1120" height="48" rx="14" fill="rgba(96,165,250,.18)" />
  <text class="caption" x="64" y="651">1. First, the request enters the system.</text>
</g>
```

```css
.caption {
  fill: var(--text);
  font-size: 16px;
  font-weight: 700;
}

.step {
  opacity: 0;
  animation: stepFade 20s linear infinite;
}

.step-1 { animation-delay: 0s; }
.step-2 { animation-delay: 4s; }
.step-3 { animation-delay: 8s; }
.step-4 { animation-delay: 12s; }
.step-5 { animation-delay: 16s; }

@keyframes stepFade {
  0%, 2% { opacity: 0; }
  4%, 17% { opacity: 1; }
  19%, 100% { opacity: 0; }
}
```

## Explanation cards

Below the diagram, add 3–5 short cards.

Good:

```html
<section class="explanation">
  <div class="note">
    <b>Desired state</b>
    <span>You describe what should exist. The system keeps trying to make reality match it.</span>
  </div>
  <div class="note">
    <b>Workers</b>
    <span>Worker machines run the actual app containers.</span>
  </div>
  <div class="note">
    <b>Repair loop</b>
    <span>If something dies, the control loop creates a replacement.</span>
  </div>
</section>
```

Bad:

- long paragraphs
- copied documentation
- too much jargon
- every edge case

## Optional interactivity

Use interactivity only if it improves learning.

Allowed:

- hover shows short detail
- click highlights one component
- next/back step buttons
- pause/play animation

Avoid:

- complex menus
- draggable canvas
- zoom/pan
- hidden critical information
- heavy JavaScript frameworks

If adding buttons, keep them simple and accessible.

## Anti-patterns

Do not:

- Generate Mermaid
- Generate PNG
- Generate React
- Use external libraries
- Use canvas
- Use complicated physics animation
- Use tiny unreadable labels
- Use more than 7 main nodes for beginners
- Explain everything in one diagram
- Add animations that do not teach
- Add realistic icons that require external assets
- Depend on internet access
- Put huge paragraphs inside SVG
- Use random colors without meaning
- Make the diagram look like a cloud vendor architecture poster
- Overfit to implementation details before explaining the mental model

## Quality checklist

Before finishing, verify:

- [ ] `index.html` exists
- [ ] file is self-contained
- [ ] no external dependencies
- [ ] opens directly in browser
- [ ] uses inline SVG
- [ ] has clear title and subtitle
- [ ] has one main visual metaphor
- [ ] has 4–7 main visual objects for beginner mode
- [ ] animation explains the concept
- [ ] no overcrowding
- [ ] reduced-motion CSS exists
- [ ] SVG has `role="img"`, `<title>`, and `<desc>`
- [ ] mobile layout works
- [ ] explanation cards are short
- [ ] labels are readable
- [ ] colors have consistent meaning
- [ ] final answer tells the user where the file is

## Example invocation

User:

```text
Use the HTML SVG Concept Explainer Skill.
Concept: Kubernetes
Audience: beginner backend engineer
Depth: simple
Output: ./kubernetes-explainer/index.html
```

Expected behavior:

- create `./kubernetes-explainer/index.html`
- use a flow or system-map pattern
- show user/kubectl, API server, scheduler, worker nodes, pods, service
- animate request/scheduling/routing
- include short explanation cards
- do not include full production-level Kubernetes internals

## Example final response

```text
Created `./kubernetes-explainer/index.html`.

Open it in your browser.
```
