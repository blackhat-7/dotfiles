---
name: classify
description: Classify, label, route or score many text items with the local models on the user's PC - Qwen3.8 Flash-Next (the main model, default) or H2O-Lightning-4B (a decision model with calibrated probabilities, for big bulk jobs). Use when the user asks to label, triage, route or score a batch of items, or says to use H2O. Not for one-off questions you can answer yourself.
---

# Classify with the local models

| Server | Where | Speed | Use for |
|---|---|---|---|
| Flash-Next (main model, Strata) | `http://127.0.0.1:6868`, on the PC only | ~0.5-1 s per short item, thinking off | Default: anything, hard items, items that need reasoning |
| H2O-Lightning-4B | `http://pc.example.com:6872` (fallback `100.64.0.1`) | ~0.1 s per item | Thousands of items, or when calibrated probabilities matter |

Only one runs at a time: both need the whole GPU. Check which is up:

```bash
curl -s --max-time 5 http://127.0.0.1:6868/health        # Flash-Next
curl -s --max-time 5 http://pc.example.com:6872/health   # H2O
```

Never switch them yourself: stopping Flash-Next interrupts the user. For a big job that wants H2O, ask the user to run `uv run lct down local-flash && uv run lct up h2o-lightning`, and afterwards `uv run lct down h2o-lightning && uv run lct up local-flash`.

## Flash-Next

```bash
curl -s http://127.0.0.1:6868/v1/chat/completions -H 'content-type: application/json' -d '{
  "messages": [{"role": "user", "content": "<item>\n\nAnswer as JSON {\"team\": billing|shipping, \"urgent\": yes|no}. JSON only."}],
  "max_tokens": 80, "temperature": 0,
  "chat_template_kwargs": {"enable_thinking": false}
}'
```

- Thinking off for plain labels; turn it on (and raise `max_tokens`) for hard items, ~5-30 s each.
- It returns no probabilities (Strata's `logprobs` are empty), and self-reported confidence is not calibrated. If confidence matters, run hard items twice at temperature 1.0 and flag disagreements, or use H2O.
- One slot: these requests evict the user's chat prompt cache. Run bulk jobs when the user is not chatting, and say so.

## H2O-Lightning-4B (`/v1/systemone`)

```bash
curl -s http://pc.example.com:6872/v1/systemone -H 'content-type: application/json' -d '{
  "state": "<the text to judge>",
  "questions": {
    "team":   {"type": "choice", "instructions": "Which team handles this?",
               "criteria": {"billing": "Payment problems", "shipping": "Delivery problems"}},
    "urgent": {"type": "noul", "instructions": "Does this need a human now?"},
    "mood":   {"type": "score", "instructions": "How upset is the writer?", "criteria": ["Calm", "Upset", "Furious"]}
  }
}'
```

- Answers are under `answers.<name>`: `choice` → `choice` + `probabilities`; `noul` (yes/no) → `noul`, the probability of yes; `score` → `score` (expected value) + `probabilities`.
- `state` is a string or a JSON object; several questions share one read of it. Images: top-level `"images": ["data:image/png;base64,..."]`.
- Weak at math and calculations (leaderboard 26/100 there); send those items to Flash-Next.

## Bulk

Write a script that sends one request per item, one at a time (both servers run one request at a time), and saves the raw answers next to the input. Report the distribution and the low-confidence items (H2O top probability below 0.7) rather than every row. A good split: H2O labels everything, then Flash-Next with thinking re-checks the low-confidence items.
