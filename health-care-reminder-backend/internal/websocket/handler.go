package websocket

import (
	"net/http"

	"github.com/gorilla/websocket"
	"github.com/labstack/gommon/log"
)

type Handler struct {
	hub *Hub
}

func NewHandler(hub *Hub) *Handler {
	return &Handler{
		hub: hub,
	}
}

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Errorf("[Websocket-Handler] ServeHTTP: failed to upgrade connection: %v", err)
		return
	}

	client := NewClient(h.hub, conn)
	h.hub.register <- client

	go client.ReadPump()
	go client.WritePump()
}
