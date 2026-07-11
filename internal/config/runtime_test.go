package config

import "testing"

func TestDefaultValid(t *testing.T) { if err := Validate(Default()); err != nil { t.Fatal(err) } }
