package websocket

import (
	"context"
	"health-care-reminder/internal/event"
)

type Worker struct {
	bus     *event.EventBus
	emitter *Emitter
}

func NewWorker(bus *event.EventBus, emitter *Emitter) *Worker {
	return &Worker{
		bus:     bus,
		emitter: emitter,
	}
}

func (w *Worker) Start(ctx context.Context) {

	go func() {

		for {
			select {

			case evt := <-w.bus.Subscribe():
				w.emitter.Emit(evt)

			case <-ctx.Done():
				return
			}

		}

	}()
}
