package response

import (
	"health-care-reminder/internal/core/domain/entity"
	"health-care-reminder/utils/enum"
	"time"
)

type DefaultResponse struct {
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

type PatientResponse struct {
	ID        int64        `json:"id"`
	Name      string       `json:"name"`
	Code      string       `json:"code"`
	Gender    enum.Gender  `json:"gender"`
	Status    *enum.Status `json:"status,omitempty"`
	Tpm       *int64       `json:"tpm,omitempty"`
	StartTime *time.Time   `json:"start_time,omitempty"`
	EndTime   *time.Time   `json:"end_time,omitempty"`
}

type InfusionData struct {
	ID           int64       `json:"id"`
	PatientID    int64       `json:"patient_id"`
	InfusionName string      `json:"infusion_name"`
	PatientName  string      `json:"patient_name"`
	StartTime    time.Time   `json:"start_time"`
	EndTime      time.Time   `json:"end_time"`
	StoppedAt    *time.Time  `json:"stopped_at,omitempty"`
	Status       enum.Status `json:"status"`
}

type InfusionResponse struct {
	Infusion      entity.InfusionEntity `json:"infusion"`
	RemainingTime int                   `json:"remaining_time"`
	IsActive      bool                  `json:"is_active"`
}

type InfusionHandlerResponse struct {
	InfusionData  InfusionData `json:"infusion_data"`
	RemainingTime int          `json:"remaining_time"`
	IsActive      bool         `json:"is_active"`
}

type DashboardSummaryResponse struct {
	TotalPatients       int64 `json:"total_patients"`
	ActiveInfusions     int64 `json:"active_infusions"`
	EndingSoonInfusions int64 `json:"ending_infusions"`
	Completed           int64 `json:"completed"`
}

type ActivityResponse struct {
	ID        int64               `json:"id"`
	Type      enum.WebsocketEvent `json:"type"`
	PatientID int64               `json:"patient_id"`
	Message   string              `json:"message"`
	CreatedAt time.Time           `json:"created_at"`
}
