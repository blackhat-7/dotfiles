#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# ///

from __future__ import annotations

import json
import os
import shutil
from pathlib import Path
from typing import Any


def ensure_executable(path: Path) -> None:
    path.chmod(path.stat().st_mode | 0o755)


def ensure_symlink(source: Path, target: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)

    if target.is_symlink():
        if target.resolve() == source.resolve():
            return
        target.unlink()
    elif target.exists():
        if target.is_dir():
            raise RuntimeError(f"refusing to replace directory: {target}")
        target.unlink()

    target.symlink_to(source)


def ensure_file_copy(source: Path, target: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)

    if target.exists() or target.is_symlink():
        if target.is_dir() and not target.is_symlink():
            raise RuntimeError(f"refusing to replace directory: {target}")
        target.unlink()

    shutil.copy2(source, target)


def read_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise RuntimeError(f"expected JSON object: {path}")
    return data


def write_json(path: Path, data: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(data, ensure_ascii=True, indent=2) + "\n", encoding="utf-8"
    )


def merge_opencode_package(repo_root: Path, home: Path) -> None:
    source = read_json(repo_root / "opencode" / "package.json")
    target_path = home / ".config" / "opencode" / "package.json"
    target = read_json(target_path)

    for key in ("private", "type"):
        if key in source:
            target[key] = source[key]

    source_dependencies = source.get("dependencies", {})
    if not isinstance(source_dependencies, dict):
        raise RuntimeError("source package.json dependencies must be an object")

    target_dependencies = target.get("dependencies")
    if target_dependencies is None:
        target_dependencies = {}
    if not isinstance(target_dependencies, dict):
        raise RuntimeError("target package.json dependencies must be an object")

    target["dependencies"] = {**target_dependencies, **source_dependencies}
    write_json(target_path, target)


def sync_opencode_tools(repo_root: Path, home: Path) -> None:
    source_dir = repo_root / "opencode" / "tools"
    target_dir = home / ".config" / "opencode" / "tools"
    target_dir.mkdir(parents=True, exist_ok=True)

    for source in sorted(source_dir.glob("*.ts")):
        ensure_file_copy(source, target_dir / source.name)


def main() -> int:
    repo_root = Path(__file__).resolve().parent.parent
    home = Path(os.environ["HOME"]).expanduser()

    sync_opencode_tools(repo_root, home)
    merge_opencode_package(repo_root, home)

    print("Linked OpenCode tools and merged package dependencies.")
    print("Install global commands with: uv tool install --editable .")
    print(
        "If ai-tools is already installed, refresh it with: uv tool uninstall ai-tools && uv tool install --editable ."
    )
    print("Restart OpenCode to load new custom tools.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
