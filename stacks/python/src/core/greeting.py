def greet(name: str) -> str:
    if not name:
        raise ValueError("name is required")
    return f"Hello, {name}."
