// Code generated from grammar.spec; DO NOT EDIT.
package parser

import "strings"

func Parse(input string) bool {
	parts:=strings.Split(input, ":")
	return len(parts)==2 && parts[0]!="" && parts[1]!=""
}
