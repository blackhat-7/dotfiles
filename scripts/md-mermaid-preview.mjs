#!/usr/bin/env node
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

process.stdout.on("error", (error) => {
  if (error?.code === "EPIPE") process.exit(0);
  throw error;
});

const args = process.argv.slice(2);
const widthArg = args.indexOf("--width");
const width = widthArg >= 0 ? Number(args[widthArg + 1]) : process.stdout.columns || 100;
const file = args.find((arg, i) => arg !== "--width" && i !== widthArg + 1 && !arg.startsWith("-")) || "-";
const input = file === "-" ? readFileSync(0, "utf8") : readFileSync(file, "utf8");

const prefix = process.env.NPM_CONFIG_PREFIX || process.env.npm_config_prefix || join(homedir(), ".npm-global");
const rendererPaths = [
  join(prefix, "lib/node_modules/beautiful-mermaid/dist/index.js"),
  join(prefix, "lib/node_modules/pi-mermaid/node_modules/beautiful-mermaid/dist/index.js"),
];

let renderMermaidASCII;
for (const rendererPath of rendererPaths) {
  if (!existsSync(rendererPath)) continue;
  const mod = await import(pathToFileURL(rendererPath).href);
  renderMermaidASCII = mod.renderMermaidASCII || mod.renderMermaidAscii;
  if (renderMermaidASCII) break;
}

if (!renderMermaidASCII) {
  console.error("beautiful-mermaid not found. Run: npm install -g beautiful-mermaid");
  process.exit(1);
}

function visibleWidth(text) {
  return text.replace(/\x1b\[[0-9;]*m/g, "").length;
}

function wrapWords(text, max = 32) {
  const lines = [];
  let line = "";
  for (const word of text.trim().split(/\s+/)) {
    if (!line) line = word;
    else if ((line + " " + word).length <= max) line += " " + word;
    else {
      lines.push(line);
      line = word;
    }
  }
  if (line) lines.push(line);
  return lines.join("<br/>");
}

function wrapLongLabels(source) {
  return source.replace(/([A-Za-z0-9_][A-Za-z0-9_-]*)(\[|\{|\()([^\]\}\)\n]{32,})(\]|\}|\))/g, (match, id, open, label, close) => {
    if (label.includes("<br") || visibleWidth(label) <= 32) return match;
    return `${id}${open}${wrapWords(label)}${close}`;
  });
}

function clip(text) {
  const max = Math.max(20, width - 4);
  return text
    .split(/\r?\n/)
    .map((line) => (visibleWidth(line) > max ? line.slice(0, max - 1) + "…" : line))
    .join("\n");
}

function indent(text) {
  return text.split(/\r?\n/).map((line) => (line ? `    ${line}` : "")).join("\n");
}

const output = input.replace(/```mermaid\s*\n?([\s\S]*?)```/gi, (_match, source) => {
  try {
    const ascii = renderMermaidASCII(wrapLongLabels(source.trim()), {
      paddingX: 1,
      boxBorderPadding: 0,
      colorMode: "none",
    }).trimEnd();
    return `Mermaid diagram:\n\n${indent(clip(ascii))}`;
  } catch (error) {
    return `Mermaid render failed: ${error?.message || error}`;
  }
});

process.stdout.write(output);
