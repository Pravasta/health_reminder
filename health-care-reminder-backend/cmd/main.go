package main

import (
	"context"
	"health-care-reminder/config"
	"health-care-reminder/internal/adapter/handler"
	"health-care-reminder/internal/adapter/repository"
	"health-care-reminder/internal/core/service"
	"health-care-reminder/internal/event"
	"health-care-reminder/internal/infrastructure"
	"health-care-reminder/internal/scheduler"
	"health-care-reminder/internal/websocket"
	"log"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"
)

func main() {
	cfg, err := config.NewConfig()
	var wg sync.WaitGroup
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	db, err := infrastructure.ConnectDB(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	hub := websocket.NewHub()
	go hub.Run()

	wsHandler := websocket.NewHandler(hub)

	eventBus := event.NewEventBus(100)

	emitter := websocket.NewEmitter(hub)

	eventWorker := websocket.NewWorker(eventBus, emitter)
	eventWorker.Start(ctx)

	// Set up repositories, services, and handlers here using the db connection

	infusionRepo := repository.NewInfusionRepository(db.DB)
	dashboardRepo := repository.NewDashboardRepository(db.DB)
	patientRepo := repository.NewPatientRepository(db.DB)
	activityRepo := repository.NewActivityRepository(db.DB)

	infusionScheduler := scheduler.NewInfusionScheduler(
		infusionRepo,
		eventBus,
		activityRepo,
	)

	patientService := service.NewPatientService(patientRepo, eventBus, activityRepo)
	infusionService := service.NewInfusionService(infusionRepo, eventBus, infusionScheduler, activityRepo)
	dashboardService := service.NewDashboardService(dashboardRepo)
	activityService := service.NewActivityService(activityRepo)

	patientHandler := handler.NewPatientHandler(patientService)
	infusionHandler := handler.NewInfusionHandler(infusionService)
	dashboardHandler := handler.NewDashboardHandler(dashboardService)
	activityHandler := handler.NewActivityHandler(activityService)

	router := infrastructure.SetupRouter(db.DB, patientHandler, infusionHandler, wsHandler, dashboardHandler, activityHandler)

	log.Printf("Server starting on port %s", cfg.App.AppPort)

	server := &http.Server{
		Addr:    ":" + cfg.App.AppPort,
		Handler: router,
	}

	infusionScheduler.StartInfusionScheduler(ctx)

	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	<-ctx.Done()
	log.Println("Shutdown signal received")

	// Timeout shutdown 10 detik
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	// Shutdown HTTP server gracefully
	if err := server.Shutdown(shutdownCtx); err != nil {
		log.Printf("Server shutdown failed: %v\n", err)
	}

	// Tunggu scheduler selesai
	wg.Wait()

	log.Println("Server exited properly")
}
