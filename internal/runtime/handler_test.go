package runtime

import "testing"

func TestAccept(t *testing.T) { if !Accept("a:1") { t.Fatal("expected accepted event") } }
func TestRejectEmpty(t *testing.T) { if Accept("  ") { t.Fatal("expected empty event rejection") } }
func TestAcceptTrimmed(t *testing.T) { if !Accept(" a:1 ") { t.Fatal("expected trimmed event") } }
