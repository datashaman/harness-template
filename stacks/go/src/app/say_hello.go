// Package app composes core domain logic with adapters into use cases.
package app

import (
	"fmt"

	"example.com/harness/src/adapters"
	"example.com/harness/src/core"
)

// SayHello returns a timestamped greeting using the system clock.
func SayHello(name string) (string, error) {
	return SayHelloAt(adapters.SystemClock, name)
}

// SayHelloAt is the explicitly-clocked variant, intended for tests.
func SayHelloAt(clock adapters.Clock, name string) (string, error) {
	greeting, err := core.Greet(name)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("[%s] %s", clock.Now().Format("2006-01-02T15:04:05Z"), greeting), nil
}
