package config

import (
	"testing"
	"time"
)

func TestDefaultValid(t *testing.T) { if err := Validate(Default()); err != nil { t.Fatal(err) } }
func TestTimeoutRejected(t *testing.T) { s:=Default(); s.Timeout=time.Millisecond; if Validate(s)==nil { t.Fatal("expected timeout error") } }
