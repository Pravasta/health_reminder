package scheduler

import (
	"context"
	"fmt"
	"health-care-reminder/internal/adapter/repository"
	"health-care-reminder/internal/core/domain/entity"
	"health-care-reminder/internal/event"
	"health-care-reminder/utils/enum"
	"time"

	"github.com/labstack/gommon/log"
)

type InfusionSchedulerInterface interface {
	StartInfusionScheduler(ctx context.Context)
	Trigger()
}

type infusionScheduler struct {
	repo         repository.InfusionRepositoryInterface
	hub          *event.EventBus
	trigger      chan struct{}
	activityRepo repository.ActivityRepository
}

// Trigger implements InfusionSchedulerInterface.
func (i *infusionScheduler) Trigger() {
	select {
	case i.trigger <- struct{}{}:
		log.Infof("[InfusionScheduler] Triggered infusion scheduler")
	default:
		log.Infof("[InfusionScheduler] Infusion scheduler is already triggered, skipping")
	}
}

// StartInfusionScheduler implements InfusionSchedulerInterface.
func (i *infusionScheduler) StartInfusionScheduler(ctx context.Context) {

	go func() {
		for {
			nextEnd, err := i.repo.GetNextInfusionEndTime(ctx)
			if err != nil {
				log.Errorf("[InfusionScheduler] Failed to get next infusion end time: %v", err)
				// If we fail to get the next infusion end time, we should wait for a short period before trying again
				select {
				case <-time.After(5 * time.Second):
					continue
				case <-ctx.Done():
					log.Infof("[InfusionScheduler] Received stop signal, stopping infusion scheduler")
					return
				case <-i.trigger:
					log.Infof("[InfusionScheduler] Received trigger signal, running infusion scheduler job immediately")
					continue
				}
			}

			var wait time.Duration
			if nextEnd == nil {
				select {
				case <-ctx.Done():
					log.Infof("[InfusionScheduler] Received stop signal, stopping infusion scheduler")
					return
				case <-i.trigger:
					log.Infof("[InfusionScheduler] Received trigger signal, running infusion scheduler job immediately")
					continue
				}
			}

			wait = time.Until(*nextEnd)
			log.Infof("[InfusionScheduler] Next infusion end time at %v, waiting for %v", nextEnd, wait)

			if wait < 0 {
				log.Infof("[InfusionScheduler] Next infusion end time is in the past, running job immediately")
				wait = 0
			}

			timer := time.NewTimer(wait)

			select {
			case <-timer.C:
				if err := i.runJob(ctx); err != nil {
					log.Errorf("[InfusionScheduler] Failed to run infusion scheduler job: %v", err)
				}
			case <-ctx.Done():
				log.Infof("[InfusionScheduler] Received stop signal, stopping infusion scheduler")
				timer.Stop()
				return
			case <-i.trigger:
				log.Infof("[InfusionScheduler] Received trigger signal, running infusion scheduler job immediately")
				if !timer.Stop() {
					<-timer.C
				}

				continue

			}
		}
	}()

}

func (i *infusionScheduler) runJob(ctx context.Context) error {
	log.Infof("[InfusionScheduler] Running infusion scheduler job")

	infusions, err := i.repo.CompleteExpiredInfusions(ctx)
	if err != nil {
		log.Errorf("[InfusionScheduler] Failed to complete expired infusions: %v", err)
		return err
	}

	if len(infusions) == 0 {
		log.Infof("[InfusionScheduler] No expired infusions to complete")
		return nil
	}

	for _, infusion := range infusions {
		err := i.activityRepo.Create(ctx, &entity.ActivityEntity{
			PatientID: infusion.PatientID,
			Type:      enum.InfusionCompleted,
			CreatedAt: time.Now().UTC(),
			Message:   fmt.Sprintf("Infusion completed - %s", infusion.Patient.Name),
		})

		if err != nil {
			log.Errorf("[InfusionScheduler] Failed to create activity for completed infusion for patient ID %d: %v", infusion.PatientID, err)
		}
	}

	events := []string{
		string(enum.InfusionCompleted),
		string(enum.DashboardUpdated),
	}

	for _, e := range events {
		i.hub.Publish(event.Event{
			Type: e,
			Payload: map[string]interface{}{
				"patient_id":   infusions[0].PatientID,
				"patient_name": infusions[0].Patient.Name,
			},
		})
	}

	log.Infof("[InfusionScheduler] Completed %d expired infusions", len(infusions))

	return nil
}

func NewInfusionScheduler(
	repo repository.InfusionRepositoryInterface,
	hub *event.EventBus,
	activityRepo repository.ActivityRepository,
) InfusionSchedulerInterface {
	return &infusionScheduler{
		repo:         repo,
		hub:          hub,
		trigger:      make(chan struct{}, 1),
		activityRepo: activityRepo,
	}
}
