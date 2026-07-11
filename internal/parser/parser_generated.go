// Code generated from grammar.spec; DO NOT EDIT.
package parser

import "strings"

func Parse(input string) bool { return len(input) > 2 && strings.Contains(input, ":") }
