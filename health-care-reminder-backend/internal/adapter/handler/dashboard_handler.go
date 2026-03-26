package handler

import (
	"health-care-reminder/internal/adapter/dto/response"
	"health-care-reminder/internal/core/service"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/labstack/gommon/log"
)

type DashboardHandlerInterface interface {
	GetDashboardSummary(c *gin.Context)
}

type dashboardHandler struct {
	dashboardService service.DashboardServiceInterface
}

// GetDashboardSummary implements DashboardHandlerInterface.
func (d *dashboardHandler) GetDashboardSummary(c *gin.Context) {
	var (
		ctx               = c.Request.Context()
		resp              = response.DefaultResponse{}
		dashboardResponse = response.DashboardSummaryResponse{}
	)

	dashboardSummary, err := d.dashboardService.GetDashboardSummary(ctx)
	if err != nil {
		log.Errorf("[DashboardHandler-0] GetDashboardSummary: failed to get dashboard summary: %v", err)
		resp.Message = "Gagal mengambil ringkasan dashboard"
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	dashboardResponse.TotalPatients = dashboardSummary.Patients
	dashboardResponse.ActiveInfusions = dashboardSummary.ActiveInfusions
	dashboardResponse.EndingSoonInfusions = dashboardSummary.InfusionEndingSoon
	dashboardResponse.Completed = dashboardSummary.InfusionCompleted

	resp.Message = "Ringkasan dashboard berhasil diambil"
	resp.Data = dashboardResponse
	c.JSON(http.StatusOK, resp)
}

func NewDashboardHandler(dashboardService service.DashboardServiceInterface) DashboardHandlerInterface {
	return &dashboardHandler{dashboardService: dashboardService}
}
