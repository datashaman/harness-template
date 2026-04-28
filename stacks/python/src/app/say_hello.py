from src.adapters import Clock, system_clock
from src.core import greet


def say_hello(name: str, clock: Clock = system_clock) -> str:
    return f"[{clock.now().isoformat()}] {greet(name)}"
