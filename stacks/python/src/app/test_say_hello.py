from datetime import UTC, datetime

import pytest

from src.adapters import Clock

from .say_hello import say_hello


class _FixedClock(Clock):
    def now(self) -> datetime:
        return datetime(2026, 4, 28, 12, 0, 0, tzinfo=UTC)


def test_prefixes_greeting_with_clock_timestamp() -> None:
    assert say_hello("Ada", _FixedClock()) == "[2026-04-28T12:00:00+00:00] Hello, Ada."


def test_propagates_name_validation() -> None:
    with pytest.raises(ValueError, match="name is required"):
        say_hello("", _FixedClock())
