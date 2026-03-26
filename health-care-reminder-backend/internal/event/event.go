package event

type Event struct {
	Type     string      `json:"type"`
	DeviceID string      `json:"device_id,omitempty"`
	Payload  interface{} `json:"payload,omitempty"`
}
