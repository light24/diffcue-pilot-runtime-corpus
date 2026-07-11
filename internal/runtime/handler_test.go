package runtime

import "testing"

func TestAccept(t *testing.T) { if !Accept("a:1") { t.Fatal("expected accepted event") } }
