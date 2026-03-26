package websocket

import (
	"encoding/json"
	"health-care-reminder/internal/event"
)

type Emitter struct {
	hub *Hub
}

func NewEmitter(hub *Hub) *Emitter {
	return &Emitter{
		hub: hub,
	}
}

func (e *Emitter) Emit(evt event.Event) {

	msg, err := json.Marshal(evt)
	if err != nil {
		return
	}

	e.hub.Broadcast(msg)
}
