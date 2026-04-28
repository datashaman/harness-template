package app

import (
	"fmt"

	"example.com/harness/src/adapters"
	"example.com/harness/src/core"
)

func SayHello(clock adapters.Clock, name string) (string, error) {
	greeting, err := core.Greet(name)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("[%s] %s", clock.Now().Format("2006-01-02T15:04:05Z"), greeting), nil
}
