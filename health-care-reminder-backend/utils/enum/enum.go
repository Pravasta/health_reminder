package enum

type Gender string

const (
	Male   Gender = "male"
	Female Gender = "female"
)

type Status string

const (
	Scheduled Status = "scheduled"
	Stopped   Status = "stopped"
	Running   Status = "running"
	Completed Status = "completed"
)

type WebsocketEvent string

const (
	PatientCreated    WebsocketEvent = "patient_created"
	InfusionCreated   WebsocketEvent = "infusion_created"
	InfusionStopped   WebsocketEvent = "infusion_stopped"
	InfusionCompleted WebsocketEvent = "infusion_completed"
	PatientDeleted    WebsocketEvent = "patient_deleted"
	DashboardUpdated  WebsocketEvent = "dashboard_updated"
)
