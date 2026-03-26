package entity

import (
	"health-care-reminder/utils/enum"
	"time"
)

type ActivityEntity struct {
	ID        int64
	Type      enum.WebsocketEvent
	PatientID int64
	Message   string
	CreatedAt time.Time
}
