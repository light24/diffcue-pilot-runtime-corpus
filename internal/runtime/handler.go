package runtime

import "github.com/light24/diffcue-pilot-acceptance/internal/parser"

func Accept(input string) bool { return parser.Parse(input) }
