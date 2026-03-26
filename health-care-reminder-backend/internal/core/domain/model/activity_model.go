package model

import (
	"health-care-reminder/utils/enum"
	"time"
)

type ActivityModel struct {
	ID        int64
	Type      enum.WebsocketEvent
	PatientID int64
	Message   string
	CreatedAt time.Time
}

// tableName
func (ActivityModel) TableName() string {
	return "activity_logs"
}
