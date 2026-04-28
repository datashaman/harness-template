// Package adapters wraps I/O at the boundaries: HTTP, DB, queues, filesystem, time.
package adapters

import "time"

// Clock returns the current time. Replace with a fake in tests.
type Clock interface {
	Now() time.Time
}

type systemClock struct{}

func (systemClock) Now() time.Time { return time.Now().UTC() }

// SystemClock is the default Clock backed by time.Now in UTC.
var SystemClock Clock = systemClock{}
