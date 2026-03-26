package handler

import (
	"health-care-reminder/internal/adapter/dto/response"
	"health-care-reminder/internal/core/service"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type ActivityHandler interface {
	GetRecentActivities(c *gin.Context)
}

type activityHandler struct {
	activityService service.ActivityService
}

// GetRecentActivities implements ActivityHandler.
func (a *activityHandler) GetRecentActivities(c *gin.Context) {
	var (
		requestLimit     = c.Query("limit")
		ctx              = c.Request.Context()
		resp             = response.DefaultResponse{}
		activityResponse = []response.ActivityResponse{}
	)

	limit := 10 // default limit

	if requestLimit == "" {
		if parsed, err := strconv.Atoi(requestLimit); err == nil && parsed > 0 {
			limit = parsed
		}
	}

	activities, err := a.activityService.GetRecentActivities(ctx, limit)
	if err != nil {

		resp.Message = "Gagal mengambil aktivitas terbaru"
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	if len(activities) == 0 {
		resp.Message = "Tidak ada aktivitas terbaru yang ditemukan"
		c.JSON(http.StatusOK, resp)
		return
	}

	for _, activity := range activities {
		activityResponse = append(activityResponse, response.ActivityResponse{
			ID:        activity.ID,
			Type:      activity.Type,
			PatientID: activity.PatientID,
			Message:   activity.Message,
			CreatedAt: activity.CreatedAt,
		})
	}

	resp.Message = "Aktivitas terbaru berhasil diambil"
	resp.Data = activityResponse
	c.JSON(http.StatusOK, resp)
}

func NewActivityHandler(activityService service.ActivityService) ActivityHandler {
	return &activityHandler{
		activityService: activityService,
	}
}
