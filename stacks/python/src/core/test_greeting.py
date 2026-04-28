import pytest

from .greeting import greet


def test_greets_a_name() -> None:
    assert greet("Ada") == "Hello, Ada."


def test_rejects_empty_name() -> None:
    with pytest.raises(ValueError, match="name is required"):
        greet("")
