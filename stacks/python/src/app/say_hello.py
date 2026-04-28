from src.adapters import Clock
from src.core import greet


def say_hello(clock: Clock, name: str) -> str:
    return f"[{clock.now().isoformat()}] {greet(name)}"
