// Package core holds pure domain logic with no I/O dependencies.
package core

import "fmt"

// Greet returns a greeting for name. It returns an error if name is empty.
func Greet(name string) (string, error) {
	if name == "" {
		return "", fmt.Errorf("name is required")
	}
	return fmt.Sprintf("Hello, %s.", name), nil
}
