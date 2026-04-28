// Structural fitness test. Fails if module-boundary invariants from
// docs/architecture.md are violated. Runs as part of `go test ./...`.
package checks

import (
	"go/parser"
	"go/token"
	"path/filepath"
	"strings"
	"testing"
)

var allowed = map[string]map[string]bool{
	"core":      {"core": true},
	"adapters":  {"core": true, "adapters": true},
	"app":       {"core": true, "adapters": true, "app": true},
	"interface": {"app": true, "interface": true},
}

func layerOf(path string) string {
	for _, layer := range []string{"core", "adapters", "app", "interface"} {
		if strings.Contains(path, "/"+layer+"/") {
			return layer
		}
	}
	return ""
}

func TestArchitectureBoundaries(t *testing.T) {
	files, err := filepath.Glob("../**/*.go")
	if err != nil {
		t.Fatal(err)
	}
	for _, f := range files {
		layer := layerOf(f)
		if layer == "" {
			continue
		}
		fset := token.NewFileSet()
		ast, err := parser.ParseFile(fset, f, nil, parser.ImportsOnly)
		if err != nil {
			t.Fatalf("%s: %v", f, err)
		}
		for _, imp := range ast.Imports {
			path := strings.Trim(imp.Path.Value, `"`)
			target := layerOf("/" + path + "/")
			if target == "" {
				continue
			}
			if !allowed[layer][target] {
				t.Errorf("%s (%s) imports %s (%s): violates docs/architecture.md",
					f, layer, path, target)
			}
		}
	}
}
