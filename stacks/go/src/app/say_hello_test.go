package app

import (
	"testing"
	"time"
)

type fixedClock struct{ t time.Time }

func (c fixedClock) Now() time.Time { return c.t }

func TestSayHelloAtPrefixesWithTimestamp(t *testing.T) {
	clock := fixedClock{t: time.Date(2026, 4, 28, 12, 0, 0, 0, time.UTC)}
	got, err := SayHelloAt(clock, "Ada")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	want := "[2026-04-28T12:00:00Z] Hello, Ada."
	if got != want {
		t.Errorf("got %q, want %q", got, want)
	}
}

func TestSayHelloAtPropagatesNameValidation(t *testing.T) {
	clock := fixedClock{t: time.Now()}
	if _, err := SayHelloAt(clock, ""); err == nil {
		t.Error("expected error for empty name")
	}
}
