package runtime

import (
	"strings"
	"github.com/light24/diffcue-pilot-acceptance/internal/parser"
)

func Accept(input string) bool { return strings.TrimSpace(input) != "" && parser.Parse(input) }
