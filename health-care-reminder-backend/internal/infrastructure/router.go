package infrastructure

import (
	"health-care-reminder/internal/adapter/handler"
	"health-care-reminder/internal/websocket"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func SetupRouter(
	db *gorm.DB,
	patientHandler handler.PatientHandlerInterface,
	infusionHandler handler.InfusionHandlerInterface,
	wsHandler *websocket.Handler,
	dashboardHandler handler.DashboardHandlerInterface,
	activityHandler handler.ActivityHandler,
) *gin.Engine {
	r := gin.Default()

	r.Use(cors.New((cors.Config{
		AllowAllOrigins:  true,
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization", "Accept"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	})))

	// health check endpoint
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "OK",
			"data":    nil,
		})
	})

	r.GET("/ws", func(c *gin.Context) {
		wsHandler.ServeHTTP(c.Writer, c.Request)
	})

	api := r.Group("/api/v1")

	// patient routes
	patientGroup := api.Group("/patients")
	{
		patientGroup.POST("", patientHandler.CreatePatient)
		patientGroup.GET("", patientHandler.GetAllPatients)
		patientGroup.GET("/:id", patientHandler.GetPatientByID)
		patientGroup.DELETE("/:id", patientHandler.DeletePatient)
	}

	// infusion routes
	infusionGroup := api.Group("/infusions")
	{
		infusionGroup.POST("", infusionHandler.CreateInfusion)
		infusionGroup.GET("", infusionHandler.GetAllInfusions)
		infusionGroup.GET("/:id", infusionHandler.GetInfusionByID)
		infusionGroup.GET("/patient/:patient_id", infusionHandler.GetInfusionsByPatientID)
		infusionGroup.GET("/patient/:patient_id/running", infusionHandler.GetOngoingInfusionsByPatientID)
		infusionGroup.PUT("/:id/stop", infusionHandler.StopInfusion)
	}

	// dashboard routes
	dashboardGroup := api.Group("/dashboard")
	{
		dashboardGroup.GET("/summary", dashboardHandler.GetDashboardSummary)
		dashboardGroup.GET("/activities", activityHandler.GetRecentActivities)
	}

	return r
}
