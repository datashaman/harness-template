// Structural fitness test. Fails if module-boundary invariants from
// docs/architecture.md are violated. Runs as part of `go test ./...`.
package checks

import (
	"go/parser"
	"go/token"
	"io/fs"
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
		if strings.Contains(path, "/"+layer+"/") || strings.HasSuffix(path, "/"+layer) {
			return layer
		}
	}
	return ""
}

func sourceFiles(t *testing.T) []string {
	t.Helper()
	var files []string
	err := filepath.WalkDir("../src", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !d.IsDir() && strings.HasSuffix(path, ".go") && !strings.HasSuffix(path, "_test.go") {
			files = append(files, path)
		}
		return nil
	})
	if err != nil {
		t.Fatalf("walk: %v", err)
	}
	if len(files) == 0 {
		t.Fatal("no source files found under ../src — architecture test would silently pass")
	}
	return files
}

func checkFileImports(t *testing.T, file string) {
	t.Helper()
	layer := layerOf(file)
	if layer == "" {
		return
	}
	fset := token.NewFileSet()
	parsed, err := parser.ParseFile(fset, file, nil, parser.ImportsOnly)
	if err != nil {
		t.Fatalf("%s: %v", file, err)
	}
	for _, imp := range parsed.Imports {
		path := strings.Trim(imp.Path.Value, `"`)
		target := layerOf("/" + path + "/")
		if target == "" {
			continue
		}
		if !allowed[layer][target] {
			t.Errorf("%s (%s) imports %s (%s): violates docs/architecture.md",
				file, layer, path, target)
		}
	}
}

func TestArchitectureBoundaries(t *testing.T) {
	for _, f := range sourceFiles(t) {
		checkFileImports(t, f)
	}
}
