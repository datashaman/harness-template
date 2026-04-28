// Command cli is the entry point that composes app use cases.
package main

import (
	"fmt"
	"os"

	"example.com/harness/src/app"
)

func main() {
	name := "world"
	if len(os.Args) > 1 {
		name = os.Args[1]
	}
	out, err := app.SayHello(name)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println(out)
}
