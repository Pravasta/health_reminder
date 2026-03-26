package service

import (
	"context"
	"fmt"
	"health-care-reminder/internal/adapter/repository"
	"health-care-reminder/internal/core/domain/entity"
	"health-care-reminder/internal/event"
	"health-care-reminder/utils/enum"
	"time"

	"github.com/labstack/gommon/log"
)

type PatientServiceInterface interface {
	Create(ctx context.Context, req *entity.PatientEntity) error
	FindAll(ctx context.Context) ([]*entity.PatientEntity, error)
	FindByID(ctx context.Context, id int64) (*entity.PatientEntity, error)
	Delete(ctx context.Context, id int64) error
}

type patientService struct {
	repo         repository.PatientRepositoryInterface
	hub          *event.EventBus
	activityRepo repository.ActivityRepository
}

// Create implements PatientServiceInterface.
func (p *patientService) Create(ctx context.Context, req *entity.PatientEntity) error {
	id, err := p.repo.Create(ctx, req)
	if err != nil {
		log.Errorf("[PatientService-0] Create: failed to create patient: %v", err)
		return err
	}

	// Create activity for patient creation
	if err := p.activityRepo.Create(ctx, &entity.ActivityEntity{
		PatientID: id,
		Type:      enum.PatientCreated,
		CreatedAt: time.Now().UTC(),
		Message:   fmt.Sprintf("Patient created - %s", req.Name),
	}); err != nil {
		log.Errorf("[PatientService-1] Create: failed to create activity for patient creation: %v", err)
	}

	p.hub.Publish(event.Event{
		Type: string(enum.PatientCreated),
	})

	return nil
}

// Delete implements PatientServiceInterface.
func (p *patientService) Delete(ctx context.Context, id int64) error {
	if err := p.repo.Delete(ctx, id); err != nil {
		log.Errorf("[PatientService-1] Delete: failed to delete patient with id %d: %v", id, err)
		return err
	}

	// Create activity for patient deletion
	if err := p.activityRepo.Create(ctx, &entity.ActivityEntity{
		PatientID: id,
		Type:      enum.PatientDeleted,
		CreatedAt: time.Now().UTC(),
		Message:   fmt.Sprintf("Patient with id %d deleted", id),
	}); err != nil {
		log.Errorf("[PatientService-2] Delete: failed to create activity for patient deletion: %v", err)
	}

	p.hub.Publish(event.Event{
		Type: string(enum.PatientDeleted),
	})

	return nil
}

// FindAll implements PatientServiceInterface.
func (p *patientService) FindAll(ctx context.Context) ([]*entity.PatientEntity, error) {
	patients, err := p.repo.FindAll(ctx)
	if err != nil {
		log.Errorf("[PatientService-3] FindAll: failed to find patients: %v", err)
		return nil, err
	}

	return patients, nil
}

// FindByID implements PatientServiceInterface.
func (p *patientService) FindByID(ctx context.Context, id int64) (*entity.PatientEntity, error) {
	patient, err := p.repo.FindByID(ctx, id)
	if err != nil {
		log.Errorf("[PatientService-2] FindByID: failed to find patient with id %d: %v", id, err)
		return nil, err
	}

	return patient, nil
}

func NewPatientService(repo repository.PatientRepositoryInterface, hub *event.EventBus, activityRepo repository.ActivityRepository) PatientServiceInterface {
	return &patientService{repo: repo, hub: hub, activityRepo: activityRepo}
}
