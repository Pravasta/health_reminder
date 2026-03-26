package model

import (
	"health-care-reminder/utils/enum"
	"time"
)

type InfusionModel struct {
	ID           int64
	PatientID    int64
	InfusionName string
	TPM          int64
	StartTime    time.Time
	EndTime      time.Time
	StoppedAt    *time.Time
	Status       enum.Status
	CreatedAt    time.Time
	UpdatedAt    time.Time
	Patient      PatientModel `gorm:"foreignKey:PatientID;references:ID"`
}

// tableName
func (InfusionModel) TableName() string {
	return "infusions"
}
