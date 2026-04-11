from __future__ import annotations

import json
import sys
from typing import Any

from ai_tools.core.errors import ToolError
from ai_tools.core.registry import registry
from ai_tools.tools import reddit  # noqa: F401


def main(argv: list[str] | None = None) -> int:
    args = argv if argv is not None else sys.argv[1:]
    if len(args) != 2:
        print("usage: ai-tools-cli <tool-name> <json-args>", file=sys.stderr)
        return 1

    tool_name, raw_args = args
    try:
        payload = json.loads(raw_args)
    except json.JSONDecodeError as exc:
        print(json.dumps({"error": f"invalid json: {exc.msg}"}), file=sys.stderr)
        return 1

    if not isinstance(payload, dict):
        print(json.dumps({"error": "tool args must be a JSON object"}), file=sys.stderr)
        return 1

    try:
        result = registry.get(tool_name).handler(payload)
    except KeyError as exc:
        print(json.dumps({"error": str(exc)}), file=sys.stderr)
        return 1
    except ToolError as exc:
        print(json.dumps({"error": str(exc)}), file=sys.stderr)
        return 1

    print(json.dumps(result, ensure_ascii=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
