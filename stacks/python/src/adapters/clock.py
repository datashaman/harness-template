from __future__ import annotations

from dataclasses import dataclass
from datetime import UTC, datetime
from typing import Protocol


class Clock(Protocol):
    def now(self) -> datetime: ...


@dataclass(frozen=True)
class _SystemClock:
    def now(self) -> datetime:
        return datetime.now(tz=UTC)


system_clock: Clock = _SystemClock()
