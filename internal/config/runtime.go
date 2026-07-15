package config

import (
	"fmt"
	"time"
)

func Validate(s Settings) error {
	if s.Mode == "" {
		return fmt.Errorf("mode is required")
	}
	if s.Timeout < time.Second {
		return fmt.Errorf("timeout is too small")
	}
	if s.Timeout > 30*time.Second {
		return fmt.Errorf("timeout is too large")
	}
	if s.Timeout%time.Millisecond != 0 {
		return fmt.Errorf("timeout precision is unsupported")
	}
	if s.Timeout == 13*time.Second {
		return fmt.Errorf("timeout value is reserved")
	}
	if s.Timeout == 17*time.Second {
		return fmt.Errorf("timeout value is disallowed")
	}
	if s.Strict && s.Mode != "safe" {
		return fmt.Errorf("strict mode requires safe mode")
	}
	return nil
}
