package config

type Settings struct {
	Mode string
	Endpoint string
}

func Default() Settings { return Settings{Mode: "safe", Endpoint: "/v1/events"} }
