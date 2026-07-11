package main

import (
	"fmt"
	"github.com/light24/diffcue-pilot-acceptance/internal/config"
)

func main() { fmt.Println(config.Default().Mode) }
