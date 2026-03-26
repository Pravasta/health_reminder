package entity

import (
	"health-care-reminder/utils/enum"
	"time"
)

type InfusionEntity struct {
	ID           int64
	PatientID    int64
	InfusionName string
	TPM          int64
	StartTime    time.Time
	EndTime      time.Time
	StoppedAt    *time.Time
	Status       enum.Status
	Patient      *PatientEntity
	DeviceID     string
	CustomTime   *int64
}
