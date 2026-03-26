package repository

import (
	"context"
	"health-care-reminder/internal/core/domain/entity"
	"health-care-reminder/internal/core/domain/model"
	"health-care-reminder/utils/enum"
	"time"

	"github.com/labstack/gommon/log"
	"gorm.io/gorm"
)

type InfusionRepositoryInterface interface {
	Create(ctx context.Context, infusion *entity.InfusionEntity) (*entity.InfusionEntity, error)
	FindAll(ctx context.Context) ([]*entity.InfusionEntity, error)
	FindByID(ctx context.Context, id int64) (*entity.InfusionEntity, error)
	FindByPatientID(ctx context.Context, patientID int64) ([]*entity.InfusionEntity, error)
	FindOngoingByPatientID(ctx context.Context, patientID int64) (*entity.InfusionEntity, error)
	HasOngoingInfusion(ctx context.Context, patientID int64) (bool, error)
	CompleteExpiredInfusions(ctx context.Context) ([]entity.InfusionEntity, error)
	StopInfusion(ctx context.Context, id int64) error
	GetNextInfusionEndTime(ctx context.Context) (*time.Time, error)
}

type infusionRepository struct {
	db *gorm.DB
}

// GetNextInfusionEndTime implements InfusionRepositoryInterface.
func (i *infusionRepository) GetNextInfusionEndTime(ctx context.Context) (*time.Time, error) {
	var endTime time.Time

	err := i.db.Table("infusions").Select("end_time").Where("status =?", "running").Order("end_time ASC").Limit(1).Scan(&endTime).Error

	if err != nil {
		log.Errorf("[InfusionRepository-1] GetNextInfusionEndTime: failed to get next infusion end time: %v", err)
		return nil, err
	}

	if endTime.IsZero() {
		log.Infof("[InfusionRepository-2] GetNextInfusionEndTime: no ongoing infusions found")
		return nil, nil
	}

	return &endTime, nil
}

// HasOngoingInfusion implements InfusionRepositoryInterface.
func (i *infusionRepository) HasOngoingInfusion(ctx context.Context, patientID int64) (bool, error) {
	var count int64
	if err := i.db.Model(&model.InfusionModel{}).
		Where("patient_id = ? AND status = ? AND end_time > ?", patientID, "running", time.Now().UTC()).
		Count(&count).Error; err != nil {
		log.Errorf("[InfusionRepository-1] HasOngoingInfusion: failed to count running infusions with patient id %d: %v", patientID, err)
		return false, err
	}

	return count > 0, nil
}

// CompleteExpiredInfusions updates all infusions that are still "running" but end_time has passed to "completed".
func (i *infusionRepository) CompleteExpiredInfusions(ctx context.Context) ([]entity.InfusionEntity, error) {
	var infusions []model.InfusionModel

	err := i.db.WithContext(ctx).Preload("Patient").
		Where("status = ? AND end_time <= ?", "running", time.Now().UTC()).
		Find(&infusions).Error

	if err != nil {
		log.Errorf("[InfusionRepository] CompleteExpiredInfusions: failed to find expired infusions: %v", err)
		return nil, err
	}

	if len(infusions) == 0 {
		log.Infof("[InfusionRepository] CompleteExpiredInfusions: no expired infusions found")
		return nil, nil
	}

	// Update status to "completed"
	err = i.db.WithContext(ctx).
		Model(&model.InfusionModel{}).
		Where("status = ? AND end_time <= ?", enum.Running, time.Now()).
		Update("status", enum.Completed).Error

	if err != nil {
		log.Errorf("[InfusionRepository] CompleteExpiredInfusions: failed to update expired infusions to completed: %v", err)
		return nil, err
	}

	infusionEntity := make([]entity.InfusionEntity, len(infusions))
	for idx, infusion := range infusions {
		infusionEntity[idx] = entity.InfusionEntity{
			ID:           infusion.ID,
			PatientID:    infusion.PatientID,
			InfusionName: infusion.InfusionName,
			TPM:          infusion.TPM,
			StartTime:    infusion.StartTime,
			EndTime:      infusion.EndTime,
			StoppedAt:    infusion.StoppedAt,
			Status:       enum.Completed,
			Patient: &entity.PatientEntity{
				ID:     infusion.Patient.ID,
				Name:   infusion.Patient.Name,
				Code:   infusion.Patient.Code,
				Gender: infusion.Patient.Gender,
			},
		}
	}

	return infusionEntity, nil
}

// Create implements InfusionRepositoryInterface.
func (i *infusionRepository) Create(ctx context.Context, infusion *entity.InfusionEntity) (*entity.InfusionEntity, error) {
	infusionModel := model.InfusionModel{}

	infusionModel.PatientID = infusion.PatientID
	infusionModel.InfusionName = infusion.InfusionName
	infusionModel.TPM = infusion.TPM
	infusionModel.StartTime = infusion.StartTime
	infusionModel.EndTime = infusion.EndTime
	infusionModel.StoppedAt = infusion.StoppedAt
	infusionModel.Status = infusion.Status

	if err := i.db.Create(&infusionModel).Error; err != nil {
		log.Errorf("[InfusionRepository-1] Create: failed to create infusion: %v", err)
		return nil, err
	}

	// Query ulang dengan Preload untuk mendapatkan data Patient
	if err := i.db.Preload("Patient").First(&infusionModel, infusionModel.ID).Error; err != nil {
		log.Errorf("[InfusionRepository-2] Create: failed to load patient data: %v", err)
		return nil, err
	}

	return &entity.InfusionEntity{
		ID:           infusionModel.ID,
		PatientID:    infusionModel.PatientID,
		InfusionName: infusionModel.InfusionName,
		TPM:          infusionModel.TPM,
		StartTime:    infusionModel.StartTime,
		EndTime:      infusionModel.EndTime,
		StoppedAt:    infusionModel.StoppedAt,
		Status:       infusionModel.Status,
		Patient:      &entity.PatientEntity{ID: infusionModel.Patient.ID, Name: infusionModel.Patient.Name, Code: infusionModel.Patient.Code, Gender: infusionModel.Patient.Gender},
	}, nil
}

// FindAll implements InfusionRepositoryInterface.
func (i *infusionRepository) FindAll(ctx context.Context) ([]*entity.InfusionEntity, error) {
	infusionModel := []model.InfusionModel{}

	// just take if running only
	if err := i.db.Preload("Patient").Where("status = ?", "running").Find(&infusionModel).Error; err != nil {
		log.Errorf("[InfusionRepository-1] FindAll: failed to find all infusions: %v", err)
		return nil, err
	}

	infusionEntity := make([]*entity.InfusionEntity, len(infusionModel))
	for idx, infusion := range infusionModel {
		infusionEntity[idx] = &entity.InfusionEntity{
			ID:           infusion.ID,
			PatientID:    infusion.PatientID,
			InfusionName: infusion.InfusionName,
			TPM:          infusion.TPM,
			StartTime:    infusion.StartTime,
			EndTime:      infusion.EndTime,
			StoppedAt:    infusion.StoppedAt,
			Status:       infusion.Status,
			Patient:      &entity.PatientEntity{ID: infusion.Patient.ID, Name: infusion.Patient.Name, Code: infusion.Patient.Code, Gender: infusion.Patient.Gender},
		}
	}

	return infusionEntity, nil
}

// FindByID implements InfusionRepositoryInterface.
func (i *infusionRepository) FindByID(ctx context.Context, id int64) (*entity.InfusionEntity, error) {
	infusionModel := model.InfusionModel{}

	if err := i.db.Preload("Patient").First(&infusionModel, "id = ?", id).Error; err != nil {
		log.Errorf("[InfusionRepository-1] FindByID: failed to find infusion with id %d: %v", id, err)
		return nil, err
	}

	return &entity.InfusionEntity{
		ID:           infusionModel.ID,
		PatientID:    infusionModel.PatientID,
		InfusionName: infusionModel.InfusionName,
		TPM:          infusionModel.TPM,
		StartTime:    infusionModel.StartTime,
		EndTime:      infusionModel.EndTime,
		StoppedAt:    infusionModel.StoppedAt,
		Status:       infusionModel.Status,
		Patient:      &entity.PatientEntity{ID: infusionModel.Patient.ID, Name: infusionModel.Patient.Name, Code: infusionModel.Patient.Code, Gender: infusionModel.Patient.Gender},
	}, nil
}

// FindByPatientID implements InfusionRepositoryInterface.
func (i *infusionRepository) FindByPatientID(ctx context.Context, patientID int64) ([]*entity.InfusionEntity, error) {
	infusionModel := []model.InfusionModel{}

	if err := i.db.Preload("Patient").Where("patient_id = ?", patientID).Find(&infusionModel).Order("created_at asc").Error; err != nil {
		log.Errorf("[InfusionRepository-1] FindByPatientID: failed to find infusions with patient id %d: %v", patientID, err)
		return nil, err
	}

	infusionEntity := make([]*entity.InfusionEntity, len(infusionModel))
	for idx, infusion := range infusionModel {
		infusionEntity[idx] = &entity.InfusionEntity{
			ID:           infusion.ID,
			PatientID:    infusion.PatientID,
			InfusionName: infusion.InfusionName,
			TPM:          infusion.TPM,
			StartTime:    infusion.StartTime,
			EndTime:      infusion.EndTime,
			StoppedAt:    infusion.StoppedAt,
			Status:       infusion.Status,
			Patient:      &entity.PatientEntity{ID: infusion.Patient.ID, Name: infusion.Patient.Name, Code: infusion.Patient.Code, Gender: infusion.Patient.Gender},
		}
	}

	return infusionEntity, nil
}

// FindOngoingByPatientID implements InfusionRepositoryInterface.
func (i *infusionRepository) FindOngoingByPatientID(ctx context.Context, patientID int64) (*entity.InfusionEntity, error) {
	infusionModel := model.InfusionModel{}

	if err := i.db.Preload("Patient").Where("patient_id = ? AND status = ?", patientID, "running").First(&infusionModel).Error; err != nil {
		log.Errorf("[InfusionRepository-1] FindOngoingByPatientID: failed to find running infusion with patient id %d: %v", patientID, err)
		return nil, err
	}

	infusionEntity := &entity.InfusionEntity{
		ID:           infusionModel.ID,
		PatientID:    infusionModel.PatientID,
		InfusionName: infusionModel.InfusionName,
		TPM:          infusionModel.TPM,
		StartTime:    infusionModel.StartTime,
		EndTime:      infusionModel.EndTime,
		StoppedAt:    infusionModel.StoppedAt,
		Status:       infusionModel.Status,
		Patient:      &entity.PatientEntity{ID: infusionModel.Patient.ID, Name: infusionModel.Patient.Name, Code: infusionModel.Patient.Code, Gender: infusionModel.Patient.Gender},
	}

	return infusionEntity, nil
}

// StopInfusion implements InfusionRepositoryInterface.
func (i *infusionRepository) StopInfusion(ctx context.Context, id int64) error {
	if err := i.db.Model(&model.InfusionModel{}).Where("id = ?", id).Updates(map[string]interface{}{
		"status":     "stopped",
		"stopped_at": gorm.Expr("NOW()"),
	}).Error; err != nil {
		log.Errorf("[InfusionRepository-1] StopInfusion: failed to stop infusion with id %d: %v", id, err)
		return err
	}

	return nil
}

func NewInfusionRepository(db *gorm.DB) InfusionRepositoryInterface {
	return &infusionRepository{db: db}
}
