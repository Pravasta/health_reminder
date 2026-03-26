package request

import "health-care-reminder/utils/enum"

type CreatePatientRequest struct {
	Name   string      `json:"name" binding:"required"`
	Code   string      `json:"code" binding:"required"`
	Gender enum.Gender `json:"gender" binding:"required"`
}

type CreateInfusionRequest struct {
	InfusionName string `json:"infusion_name" binding:"required"`
	PatientID    int64  `json:"patient_id" binding:"required"`
	TPM          int64  `json:"tpm" binding:"required"`
	DeviceID     string `json:"device_id" binding:"required"`
	CustomTime   *int64 `json:"custom_time,omitempty"`
}
