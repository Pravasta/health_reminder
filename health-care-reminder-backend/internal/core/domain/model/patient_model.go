package model

import (
	"health-care-reminder/utils/enum"
	"time"
)

type PatientModel struct {
	ID        int64
	Name      string
	Code      string
	Gender    enum.Gender
	CreatedAt time.Time
	UpdatedAt time.Time
}

// tableName
func (PatientModel) TableName() string {
	return "patients"
}
