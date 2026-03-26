package entity

type DashboardEntity struct {
	Patients           int64 `json:"total_patients" gorm:"column:total_patients"`
	ActiveInfusions    int64 `json:"ongoing_infusions" gorm:"column:ongoing_infusions"`
	InfusionEndingSoon int64 `json:"ending_soon" gorm:"column:ending_soon"`
	InfusionCompleted  int64 `json:"completed" gorm:"column:completed"`
}
