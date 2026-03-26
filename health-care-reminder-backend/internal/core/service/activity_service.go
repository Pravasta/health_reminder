package service

import (
	"context"
	"health-care-reminder/internal/adapter/repository"
	"health-care-reminder/internal/core/domain/entity"

	"github.com/labstack/gommon/log"
)

type ActivityService interface {
	CreateActivity(ctx context.Context, activity *entity.ActivityEntity) error
	GetRecentActivities(ctx context.Context, limit int) ([]*entity.ActivityEntity, error)
}

type activityService struct {
	activityRepo repository.ActivityRepository
}

// CreateActivity implements ActivityService.
func (a *activityService) CreateActivity(ctx context.Context, activity *entity.ActivityEntity) error {
	var result entity.ActivityEntity

	result.PatientID = activity.PatientID
	result.Type = activity.Type
	result.Message = activity.Message
	result.CreatedAt = activity.CreatedAt

	if err := a.activityRepo.Create(ctx, &result); err != nil {
		log.Errorf("[ActivityService-1] CreateActivity: failed to create activity for patient ID %d: %v", activity.PatientID, err)
		return err
	}

	return nil
}

// GetRecentActivities implements ActivityService.
func (a *activityService) GetRecentActivities(ctx context.Context, limit int) ([]*entity.ActivityEntity, error) {
	if limit <= 0 {
		limit = 10 // default limit
	}

	activities, err := a.activityRepo.GetRecentActivities(ctx, limit)
	if err != nil {
		log.Errorf("[ActivityService-2] GetRecentActivities: failed to get recent activities: %v", err)
		return nil, err
	}

	return activities, nil
}

func NewActivityService(activityRepo repository.ActivityRepository) ActivityService {
	return &activityService{
		activityRepo: activityRepo,
	}
}
