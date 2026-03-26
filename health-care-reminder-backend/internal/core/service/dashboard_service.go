package service

import (
	"context"
	"health-care-reminder/internal/adapter/repository"
	"health-care-reminder/internal/core/domain/entity"

	"github.com/labstack/gommon/log"
)

type DashboardServiceInterface interface {
	GetDashboardSummary(ctx context.Context) (*entity.DashboardEntity, error)
}

type dashboardService struct {
	dashboardRepository repository.DashboardRepositoryInterface
}

// GetDashboardSummary implements DashboardServiceInterface.
func (d *dashboardService) GetDashboardSummary(ctx context.Context) (*entity.DashboardEntity, error) {
	summary, err := d.dashboardRepository.GetDashboardSummary(ctx)

	if err != nil {
		log.Errorf("[DashboardService-0] GetDashboardSummary: failed to get dashboard summary: %v", err)
		return nil, err
	}

	return summary, nil
}

func NewDashboardService(dashboardRepo repository.DashboardRepositoryInterface) DashboardServiceInterface {
	return &dashboardService{dashboardRepository: dashboardRepo}
}
