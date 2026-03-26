package event

type EventBus struct {
	events chan Event
}

func NewEventBus(buffer int) *EventBus {
	return &EventBus{
		events: make(chan Event, buffer),
	}
}

func (b *EventBus) Publish(event Event) {
	b.events <- event
}

func (b *EventBus) Subscribe() <-chan Event {
	return b.events
}
