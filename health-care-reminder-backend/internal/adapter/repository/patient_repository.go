package repository

import (
	"context"
	"errors"
	"health-care-reminder/internal/adapter/message"
	"health-care-reminder/internal/core/domain/entity"
	"health-care-reminder/internal/core/domain/model"
	"health-care-reminder/utils/enum"
	"time"

	"github.com/jackc/pgx/v5/pgconn"
	"github.com/labstack/gommon/log"
	"gorm.io/gorm"
)

type PatientRepositoryInterface interface {
	Create(ctx context.Context, patient *entity.PatientEntity) (patientID int64, err error)
	FindAll(ctx context.Context) ([]*entity.PatientEntity, error)
	FindByID(ctx context.Context, id int64) (*entity.PatientEntity, error)
	Delete(ctx context.Context, id int64) error
}

type patientRepository struct {
	db *gorm.DB
}

// Create implements PatientRepositoryInterface.
func (p *patientRepository) Create(ctx context.Context, patient *entity.PatientEntity) (patientID int64, err error) {
	patientModel := model.PatientModel{}

	// create id with uuid

	patientModel.Name = patient.Name
	patientModel.Code = patient.Code
	patientModel.Gender = patient.Gender
	patientModel.CreatedAt = time.Now()

	if err := p.db.Create(&patientModel).Error; err != nil {
		// makesure code is unique
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) && pgErr.Code == "23505" {
			log.Errorf("[PatientRepository-0] Create: failed to create patient with code %s: code already exists", patient.Code)
			return 0, message.ErrDuplicateCode
		}
		log.Errorf("[PatientRepository-1] Create: failed to create patient: %v", err)
		return 0, err
	}

	return patientModel.ID, nil
}

// Delete implements PatientRepositoryInterface.
func (p *patientRepository) Delete(ctx context.Context, id int64) error {
	if err := p.db.Delete(&model.PatientModel{}, "id = ?", id).Error; err != nil {
		log.Errorf("[PatientRepository-1] Delete: failed to delete patient with id %d: %v", id, err)
		return err
	}
	return nil
}

// FindAll implements PatientRepositoryInterface.
func (p *patientRepository) FindAll(ctx context.Context) ([]*entity.PatientEntity, error) {
	var patientModels []model.PatientModel

	if err := p.db.Find(&patientModels).Error; err != nil {
		log.Errorf("[PatientRepository-1] FindAll: failed to find patients: %v", err)
		return nil, err
	}

	// Get the latest infusion per patient to determine their current status
	type latestInfusion struct {
		PatientID int64
		Status    enum.Status
		StartTime time.Time
		EndTime   time.Time
		Tpm       int64
	}
	var results []latestInfusion
	if err := p.db.Model(&model.InfusionModel{}).
		Select("patient_id, status, start_time, end_time, tpm").
		Where("id IN (?)",
			p.db.Model(&model.InfusionModel{}).
				Select("MAX(id)").
				Group("patient_id"),
		).
		Find(&results).Error; err != nil {
		log.Errorf("[PatientRepository-2] FindAll: failed to find latest infusions: %v", err)
		return nil, err
	}

	// Map patient ID to their latest infusion data
	infusionMap := make(map[int64]*latestInfusion)
	for i := range results {
		infusionMap[results[i].PatientID] = &results[i]
	}

	var patientEntities []*entity.PatientEntity
	for _, patientModel := range patientModels {
		pe := &entity.PatientEntity{
			ID:     patientModel.ID,
			Name:   patientModel.Name,
			Code:   patientModel.Code,
			Gender: patientModel.Gender,
		}

		if inf, ok := infusionMap[patientModel.ID]; ok {
			pe.Status = &inf.Status
			pe.Tpm = &inf.Tpm
			pe.StartTime = &inf.StartTime
			pe.EndTime = &inf.EndTime
		}

		patientEntities = append(patientEntities, pe)
	}

	return patientEntities, nil
}

// FindByID implements PatientRepositoryInterface.
func (p *patientRepository) FindByID(ctx context.Context, id int64) (*entity.PatientEntity, error) {
	var patientModel model.PatientModel

	if err := p.db.First(&patientModel, "id = ?", id).Error; err != nil {
		log.Errorf("[PatientRepository-1] FindByID: failed to find patient with id %d: %v", id, err)
		return nil, err
	}

	// Get the latest infusion status for this patient
	var latestInfusion model.InfusionModel
	var status *enum.Status
	if err := p.db.Where("patient_id = ?", id).Order("id DESC").First(&latestInfusion).Error; err == nil {
		status = &latestInfusion.Status
	}

	return &entity.PatientEntity{
		ID:     patientModel.ID,
		Name:   patientModel.Name,
		Code:   patientModel.Code,
		Gender: patientModel.Gender,
		Status: status,
	}, nil
}

func NewPatientRepository(db *gorm.DB) PatientRepositoryInterface {
	return &patientRepository{db: db}
}
