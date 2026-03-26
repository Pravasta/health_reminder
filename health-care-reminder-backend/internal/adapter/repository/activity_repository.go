package repository

import (
	"context"
	"health-care-reminder/internal/core/domain/entity"
	"health-care-reminder/internal/core/domain/model"

	"github.com/labstack/gommon/log"
	"gorm.io/gorm"
)

type ActivityRepository interface {
	Create(ctx context.Context, activity *entity.ActivityEntity) error
	GetRecentActivities(ctx context.Context, limit int) ([]*entity.ActivityEntity, error)
}

type activityRepository struct {
	db *gorm.DB
}

// Create implements ActivityRepository.
func (a *activityRepository) Create(ctx context.Context, activity *entity.ActivityEntity) error {
	activityModel := model.ActivityModel{}

	activityModel.PatientID = activity.PatientID
	activityModel.Type = activity.Type
	activityModel.Message = activity.Message
	activityModel.CreatedAt = activity.CreatedAt

	if err := a.db.WithContext(ctx).Create(&activityModel).Error; err != nil {
		log.Errorf("[ActivityRepository-1] Create: failed to create activity: %v", err)
		return err
	}

	return nil
}

// GetRecentActivities implements ActivityRepository.
func (a *activityRepository) GetRecentActivities(ctx context.Context, limit int) ([]*entity.ActivityEntity, error) {
	var activityModels []model.ActivityModel

	if err := a.db.WithContext(ctx).Order("created_at DESC").Limit(limit).Find(&activityModels).Error; err != nil {

		log.Errorf("[ActivityRepository-1] GetRecentActivities: failed to get recent activities: %v", err)
		return nil, err
	}

	activities := make([]*entity.ActivityEntity, len(activityModels))
	for i, model := range activityModels {
		activities[i] = &entity.ActivityEntity{
			ID:        model.ID,
			PatientID: model.PatientID,
			Type:      model.Type,
			Message:   model.Message,
			CreatedAt: model.CreatedAt,
		}
	}

	return activities, nil
}

func NewActivityRepository(db *gorm.DB) ActivityRepository {
	return &activityRepository{db: db}
}
