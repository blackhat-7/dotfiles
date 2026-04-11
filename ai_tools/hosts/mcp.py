from __future__ import annotations

import json
import sys
from typing import Any

from ai_tools.core.errors import ToolError
from ai_tools.core.registry import registry
from ai_tools.tools import reddit  # noqa: F401

PROTOCOL_VERSION = "2025-03-26"
SERVER_INFO = {"name": "ai-tools", "version": "0.1.0"}
INSTRUCTIONS = "Use these tools for safe, typed access to external services."


def main() -> int:
    for line in sys.stdin:
        if not line.strip():
            continue
        try:
            message = json.loads(line)
        except json.JSONDecodeError:
            continue

        if isinstance(message, list):
            for item in message:
                handle_message(item)
            continue

        handle_message(message)
    return 0


def handle_message(message: dict[str, Any]) -> None:
    method = message.get("method")
    message_id = message.get("id")
    params = message.get("params")

    if method == "notifications/initialized":
        return

    if method == "initialize" and message_id is not None:
        send(
            {
                "jsonrpc": "2.0",
                "id": message_id,
                "result": {
                    "protocolVersion": PROTOCOL_VERSION,
                    "capabilities": {"tools": {"listChanged": False}},
                    "serverInfo": SERVER_INFO,
                    "instructions": INSTRUCTIONS,
                },
            }
        )
        return

    if method == "ping" and message_id is not None:
        send({"jsonrpc": "2.0", "id": message_id, "result": {}})
        return

    if method == "tools/list" and message_id is not None:
        send(
            {
                "jsonrpc": "2.0",
                "id": message_id,
                "result": {
                    "tools": [
                        {
                            "name": spec.name,
                            "description": spec.description,
                            "inputSchema": spec.input_schema,
                        }
                        for spec in (registry.get(name) for name in registry.names())
                    ]
                },
            }
        )
        return

    if method == "tools/call" and message_id is not None:
        if not isinstance(params, dict):
            send_error(message_id, -32602, "Invalid params")
            return
        tool_name = params.get("name")
        tool_args = params.get("arguments", {})
        if not isinstance(tool_name, str) or not isinstance(tool_args, dict):
            send_error(message_id, -32602, "Invalid params")
            return
        try:
            result = registry.get(tool_name).handler(tool_args)
        except KeyError:
            send_error(message_id, -32602, f"Unknown tool: {tool_name}")
            return
        except ToolError as exc:
            send(
                {
                    "jsonrpc": "2.0",
                    "id": message_id,
                    "result": {
                        "content": [{"type": "text", "text": str(exc)}],
                        "isError": True,
                    },
                }
            )
            return

        send(
            {
                "jsonrpc": "2.0",
                "id": message_id,
                "result": {
                    "content": [
                        {"type": "text", "text": json.dumps(result, ensure_ascii=True)}
                    ],
                    "isError": False,
                },
            }
        )
        return

    if message_id is not None:
        send_error(message_id, -32601, f"Method not found: {method}")


def send(payload: dict[str, Any]) -> None:
    sys.stdout.write(json.dumps(payload, ensure_ascii=True) + "\n")
    sys.stdout.flush()


def send_error(message_id: Any, code: int, message: str) -> None:
    send(
        {
            "jsonrpc": "2.0",
            "id": message_id,
            "error": {"code": code, "message": message},
        }
    )


if __name__ == "__main__":
    raise SystemExit(main())
