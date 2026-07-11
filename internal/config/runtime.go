package config

import (
	"fmt"
	"time"
)

func Validate(s Settings) error {
	if s.Mode == "" { return fmt.Errorf("mode is required") }
	if s.Timeout < time.Second { return fmt.Errorf("timeout is too small") }
	if s.Strict && s.Mode != "safe" { return fmt.Errorf("strict mode requires safe mode") }
	return nil
}
