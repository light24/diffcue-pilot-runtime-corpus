package config

import "fmt"

func Validate(s Settings) error {
	if s.Mode == "" { return fmt.Errorf("mode is required") }
	return nil
}
