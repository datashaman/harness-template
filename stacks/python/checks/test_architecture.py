"""Structural fitness test. Fails if module-boundary invariants from
docs/architecture.md are violated. Runs as part of `pytest`."""

from __future__ import annotations

import ast
import pathlib

import pytest

ALLOWED: dict[str, set[str]] = {
    "core": {"core"},
    "adapters": {"core", "adapters"},
    "app": {"core", "adapters", "app"},
    "interface": {"app", "interface"},
}


def _layer_of(path: pathlib.Path) -> str | None:
    parts = path.parts
    if "src" not in parts:
        return None
    after_src = parts[parts.index("src") + 1 :]
    return after_src[0] if after_src and after_src[0] in ALLOWED else None


def _imports(path: pathlib.Path) -> list[str]:
    tree = ast.parse(path.read_text())
    out: list[str] = []
    for node in ast.walk(tree):
        if isinstance(node, ast.ImportFrom) and node.module:
            out.append(node.module)
        elif isinstance(node, ast.Import):
            out.extend(alias.name for alias in node.names)
    return out


@pytest.mark.parametrize("path", list(pathlib.Path("src").rglob("*.py")))
def test_imports_respect_layer(path: pathlib.Path) -> None:
    layer = _layer_of(path)
    if layer is None:
        return
    for spec in _imports(path):
        target = next((p for p in spec.split(".") if p in ALLOWED), None)
        if target is None:
            continue
        assert target in ALLOWED[layer], (
            f"{path} ({layer}) → {spec} ({target}) violates docs/architecture.md"
        )
