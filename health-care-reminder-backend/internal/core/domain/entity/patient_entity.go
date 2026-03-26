package entity

import (
	"health-care-reminder/utils/enum"
	"time"
)

type PatientEntity struct {
	ID        int64
	Name      string
	Code      string
	Gender    enum.Gender
	Status    *enum.Status
	Tpm       *int64
	StartTime *time.Time
	EndTime   *time.Time
}
