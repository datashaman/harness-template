package core

import "fmt"

func Greet(name string) (string, error) {
	if name == "" {
		return "", fmt.Errorf("name is required")
	}
	return fmt.Sprintf("Hello, %s.", name), nil
}
