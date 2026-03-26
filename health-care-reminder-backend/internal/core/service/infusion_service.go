package service

import (
	"context"
	"errors"
	"fmt"
	"health-care-reminder/internal/adapter/dto/response"
	"health-care-reminder/internal/adapter/repository"
	"health-care-reminder/internal/core/domain/entity"
	"health-care-reminder/internal/event"
	"health-care-reminder/internal/scheduler"
	"health-care-reminder/utils/enum"
	"time"

	"github.com/labstack/gommon/log"
)

type InfusionServiceInterface interface {
	Create(ctx context.Context, infusion *entity.InfusionEntity) (*response.InfusionResponse, error)
	FindAll(ctx context.Context) ([]*response.InfusionResponse, error)
	FindByID(ctx context.Context, id int64) (*response.InfusionResponse, error)
	FindByPatientID(ctx context.Context, patientID int64) ([]*response.InfusionResponse, error)
	FindOngoingByPatientID(ctx context.Context, patientID int64) (*response.InfusionResponse, error)
	StopInfusion(ctx context.Context, id int64) error
	enrichInfusionResponse(infusion entity.InfusionEntity) *response.InfusionResponse
}

type infusionService struct {
	infusionRepository repository.InfusionRepositoryInterface
	hub                *event.EventBus
	scheduler          scheduler.InfusionSchedulerInterface
	activityRepo       repository.ActivityRepository
}

// Create implements InfusionServiceInterface.
func (i *infusionService) Create(ctx context.Context, infusion *entity.InfusionEntity) (*response.InfusionResponse, error) {

	// Only One Running Infusion per Patient
	hasOngoingInfusion, err := i.infusionRepository.HasOngoingInfusion(ctx, infusion.PatientID)
	if err != nil {
		log.Errorf("[InfusionService-0] Create: failed to check ongoing infusion: %v", err)
		return nil, err
	}

	if hasOngoingInfusion {
		log.Errorf("[InfusionService-1] Create: patient with id %d has ongoing infusion", infusion.PatientID)
		return nil, errors.New("Patient has ongoing infusion")
	}

	var appliedTime int64

	infusion.StartTime = time.Now().UTC()
	if infusion.CustomTime != nil {
		appliedTime = *infusion.CustomTime
	} else {
		appliedTime = infusion.TPM
	}

	infusion.EndTime = infusion.StartTime.Add(time.Duration(appliedTime) * time.Minute)

	infusion.Status = enum.Running

	infusion, err = i.infusionRepository.Create(ctx, infusion)
	if err != nil {
		log.Errorf("[InfusionService-2] Create: failed to create infusion: %v", err)
		return nil, err
	}

	i.scheduler.Trigger()

	if err := i.activityRepo.Create(ctx, &entity.ActivityEntity{
		PatientID: infusion.PatientID,
		Type:      enum.InfusionCreated,
		CreatedAt: time.Now().UTC(),
		Message:   fmt.Sprintf("Infusion started (%s) - %s", infusion.InfusionName, infusion.Patient.Name),
	}); err != nil {
		log.Errorf("[InfusionService-3] Create: failed to create activity for infusion creation: %v", err)
	}

	i.hub.Publish(event.Event{
		DeviceID: infusion.DeviceID,
		Type:     string(enum.InfusionCreated),
	})

	return i.enrichInfusionResponse(*infusion), nil
}

// FindAll implements InfusionServiceInterface.
func (i *infusionService) FindAll(ctx context.Context) ([]*response.InfusionResponse, error) {

	infusions, err := i.infusionRepository.FindAll(ctx)
	if err != nil {
		log.Errorf("[InfusionService-4] FindAll: failed to find all infusions: %v", err)
		return nil, err
	}

	var responses []*response.InfusionResponse
	for _, infusion := range infusions {
		responses = append(responses, i.enrichInfusionResponse(*infusion))
	}

	return responses, nil
}

// FindByID implements InfusionServiceInterface.
func (i *infusionService) FindByID(ctx context.Context, id int64) (*response.InfusionResponse, error) {

	infusion, err := i.infusionRepository.FindByID(ctx, id)
	if err != nil {
		log.Errorf("[InfusionService-3] FindByID: failed to find infusion with id %d: %v", id, err)
		return nil, err
	}

	return i.enrichInfusionResponse(*infusion), nil
}

// FindByPatientID implements InfusionServiceInterface.
func (i *infusionService) FindByPatientID(ctx context.Context, patientID int64) ([]*response.InfusionResponse, error) {

	infusions, err := i.infusionRepository.FindByPatientID(ctx, patientID)
	if err != nil {
		log.Errorf("[InfusionService-4] FindByPatientID: failed to find infusions for patient with id %d: %v", patientID, err)
		return nil, err
	}

	var responses []*response.InfusionResponse
	for _, infusion := range infusions {
		responses = append(responses, i.enrichInfusionResponse(*infusion))
	}

	return responses, nil
}

// FindOngoingByPatientID implements InfusionServiceInterface.
func (i *infusionService) FindOngoingByPatientID(ctx context.Context, patientID int64) (*response.InfusionResponse, error) {

	infusion, err := i.infusionRepository.FindOngoingByPatientID(ctx, patientID)
	if err != nil {
		log.Errorf("[InfusionService-5] FindOngoingByPatientID: failed to find ongoing infusion for patient with id %d: %v", patientID, err)
		return nil, err
	}

	return i.enrichInfusionResponse(*infusion), nil
}

// StopInfusion implements InfusionServiceInterface.
func (i *infusionService) StopInfusion(ctx context.Context, id int64) error {
	if err := i.infusionRepository.StopInfusion(ctx, id); err != nil {
		log.Errorf("[InfusionService-6] StopInfusion: failed to stop infusion with id %d: %v", id, err)
		return err
	}

	i.hub.Publish(event.Event{
		Type: string(enum.InfusionStopped),
	})

	return nil
}

func (i *infusionService) enrichInfusionResponse(infusion entity.InfusionEntity) *response.InfusionResponse {
	now := time.Now().UTC()
	remainingTime := 0
	status := infusion.Status

	switch status {
	case enum.Stopped:
		log.Infof("[InfusionService-3] enrichInfusionResponse: infusion with id %d is stopped", infusion.ID)
		if infusion.StoppedAt != nil {
			if infusion.StoppedAt.After(*infusion.StoppedAt) {
				remainingTime = int(infusion.EndTime.Sub(*infusion.StoppedAt).Minutes())
			}
		}
	case enum.Completed:
		log.Infof("[InfusionService-3] enrichInfusionResponse: infusion with id %d is completed", infusion.ID)
		remainingTime = 0
	case enum.Running:
		log.Infof("[InfusionService-3] enrichInfusionResponse: infusion with id %d is running", infusion.ID)
		if infusion.EndTime.After(now) {
			remainingTime = int(infusion.EndTime.Sub(now).Minutes())
		}

		if now.After(infusion.EndTime) || now.Equal(infusion.EndTime) {
			remainingTime = 0
			status = enum.Completed
		}
	default:
		log.Errorf("[InfusionService-3] enrichInfusionResponse: invalid infusion status %s", status)
		return nil
	}

	infusion.Status = status

	return &response.InfusionResponse{
		Infusion:      infusion,
		RemainingTime: remainingTime,
		IsActive:      status == enum.Running,
	}
}

func NewInfusionService(infusionRepository repository.InfusionRepositoryInterface, hub *event.EventBus, scheduler scheduler.InfusionSchedulerInterface, activityRepo repository.ActivityRepository) InfusionServiceInterface {
	return &infusionService{
		infusionRepository: infusionRepository,
		hub:                hub,
		scheduler:          scheduler,
		activityRepo:       activityRepo,
	}
}
