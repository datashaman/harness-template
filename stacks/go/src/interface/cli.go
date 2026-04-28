package main

import (
	"fmt"
	"os"

	"example.com/harness/src/adapters"
	"example.com/harness/src/app"
)

func main() {
	name := "world"
	if len(os.Args) > 1 {
		name = os.Args[1]
	}
	out, err := app.SayHello(adapters.SystemClock, name)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(out)
}
