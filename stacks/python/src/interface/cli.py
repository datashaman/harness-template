import logging
import sys

from src.adapters import system_clock
from src.app import say_hello

log = logging.getLogger(__name__)


def main() -> None:
    name = sys.argv[1] if len(sys.argv) > 1 else "world"
    log.info("greet", extra={"output": say_hello(system_clock, name)})


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()
