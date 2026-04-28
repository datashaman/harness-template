package core

import "testing"

func TestGreetsAName(t *testing.T) {
	got, err := Greet("Ada")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if got != "Hello, Ada." {
		t.Errorf("got %q, want %q", got, "Hello, Ada.")
	}
}

func TestRejectsEmptyName(t *testing.T) {
	if _, err := Greet(""); err == nil {
		t.Error("expected error for empty name")
	}
}
