---
name: generate-image
description: Generate, create, render, or make images from text prompts using the user's `img` command. Use this whenever the user asks for an image, picture, illustration, render, poster, concept art, photo, logo draft, visual asset, or any prompt-to-image generation. Select cloud by default, and select local when the user asks for local/offline/private/free generation or mentions the 4070/PC.
---

# Generate Image

Use the `img` command. Do not add MCP or alternate integrations.

## Backend selection

- Default to cloud:
  ```bash
  img "exact user prompt"
  ```
- Use cloud explicitly when the user asks for cloud/fal/genmedia:
  ```bash
  img --cloud "exact user prompt"
  ```
- Use local stable-diffusion.cpp when the user says local, offline, private, free, 4070, RTX 4070, GPU, or PC:
  ```bash
  img --local "exact user prompt"
  ```

Do not rewrite, embellish, translate, or optimize the prompt unless the user explicitly asks you to. Pass the user's prompt through exactly.

## Reporting results

After generation, report only useful outputs:

- Local image path from `IMAGE_PATH=...`
- URL from `IMAGE_URL=...` when present
- Log path only if useful for debugging or if generation failed

Avoid dumping full JSON logs into chat.

## Setup errors

If cloud generation is not configured, tell the user to run:

```bash
genmedia setup
```

If local generation is not configured, tell the user to run:

```bash
img-local-setup
img-local-server
```

`img-local-server` must keep running while using `img --local`.
