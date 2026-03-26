package repository

import (
	"context"
	"health-care-reminder/internal/core/domain/entity"

	"github.com/labstack/gommon/log"
	"gorm.io/gorm"
)

type DashboardRepositoryInterface interface {
	GetDashboardSummary(ctx context.Context) (*entity.DashboardEntity, error)
}

type dashboardRepository struct {
	db *gorm.DB
}

// GetDashboardSummary implements DashboardRepositoryInterface.
func (d *dashboardRepository) GetDashboardSummary(ctx context.Context) (*entity.DashboardEntity, error) {
	var summary entity.DashboardEntity

	if err := d.db.WithContext(ctx).Raw(`
		SELECT
			(SELECT COUNT(*) FROM patients) AS total_patients,
			(SELECT COUNT(*) FROM infusions WHERE status = 'running') AS ongoing_infusions,
			(SELECT COUNT(*) FROM infusions WHERE status = 'running' AND end_time <= NOW() + INTERVAL '5 minutes') AS ending_soon,
			(SELECT COUNT(*) FROM infusions WHERE status = 'completed') AS completed
	`).Scan(&summary).Error; err != nil {
		log.Errorf("[DashboardRepository-1] GetDashboardSummary: failed to get dashboard summary: %v", err)
		return nil, err
	}

	return &summary, nil
}

func NewDashboardRepository(db *gorm.DB) DashboardRepositoryInterface {
	return &dashboardRepository{db: db}
}
