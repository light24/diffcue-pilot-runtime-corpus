package config

import (
	"testing"
	"time"
)

func TestDefaultValid(t *testing.T) {
	if err := Validate(Default()); err != nil {
		t.Fatal(err)
	}
}
func TestTimeoutRejected(t *testing.T) {
	s := Default()
	s.Timeout = time.Millisecond
	if Validate(s) == nil {
		t.Fatal("expected timeout error")
	}
}
func TestTimeoutTooLarge(t *testing.T) {
	s := Default()
	s.Timeout = time.Minute
	if Validate(s) == nil {
		t.Fatal("expected maximum-timeout error")
	}
}
func TestTimeoutPrecision(t *testing.T) {
	s := Default()
	s.Timeout = time.Second + time.Nanosecond
	if Validate(s) == nil {
		t.Fatal("expected timeout-precision error")
	}
}
func TestStrictMode(t *testing.T) {
	s := Default()
	s.Mode = "fast"
	if Validate(s) == nil {
		t.Fatal("expected strict-mode error")
	}
}
