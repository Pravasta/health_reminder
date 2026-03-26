package handler

import (
	"health-care-reminder/internal/adapter/dto/request"
	"health-care-reminder/internal/adapter/dto/response"
	"health-care-reminder/internal/core/domain/entity"
	"health-care-reminder/internal/core/service"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/labstack/gommon/log"
)

type InfusionHandlerInterface interface {
	CreateInfusion(c *gin.Context)
	GetAllInfusions(c *gin.Context)
	GetInfusionByID(c *gin.Context)
	GetInfusionsByPatientID(c *gin.Context)
	GetOngoingInfusionsByPatientID(c *gin.Context)
	StopInfusion(c *gin.Context)
}

type infusionHandler struct {
	infusionService service.InfusionServiceInterface
}

// CreateInfusion implements InfusionHandlerInterface.
func (i *infusionHandler) CreateInfusion(c *gin.Context) {
	var (
		ctx              = c.Request.Context()
		req              = request.CreateInfusionRequest{}
		resp             = response.DefaultResponse{}
		infusionResponse = response.InfusionHandlerResponse{}
	)

	if err := c.ShouldBindJSON(&req); err != nil {
		log.Errorf("[InfusionHandler-1] CreateInfusion: failed to bind request body: %v", err)
		resp.Message = "Data request tidak valid"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	// validate request body
	if req.PatientID == 0 || req.TPM == 0 {
		log.Errorf("[InfusionHandler-2] CreateInfusion: missing required fields")
		resp.Message = "PatientID dan TPM harus diisi"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	if req.InfusionName == "" {
		log.Errorf("[InfusionHandler-3] CreateInfusion: missing required fields")
		resp.Message = "InfusionName harus diisi"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	infusionEntity := entity.InfusionEntity{
		PatientID:    req.PatientID,
		InfusionName: req.InfusionName,
		TPM:          req.TPM,
		DeviceID:     req.DeviceID,
		CustomTime:   req.CustomTime,
	}

	infusionResult, err := i.infusionService.Create(ctx, &infusionEntity)
	if err != nil {
		log.Errorf("[InfusionHandler-4] CreateInfusion: failed to create infusion: %v", err)
		resp.Message = err.Error()
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	infusionData := response.InfusionData{
		ID:           infusionResult.Infusion.ID,
		PatientID:    infusionResult.Infusion.PatientID,
		InfusionName: infusionResult.Infusion.InfusionName,
		PatientName:  infusionResult.Infusion.Patient.Name,
		StartTime:    infusionResult.Infusion.StartTime,
		EndTime:      infusionResult.Infusion.EndTime,
		StoppedAt:    infusionResult.Infusion.StoppedAt,
		Status:       infusionResult.Infusion.Status,
	}

	infusionResponse.InfusionData = infusionData
	infusionResponse.RemainingTime = infusionResult.RemainingTime
	infusionResponse.IsActive = infusionResult.IsActive

	resp.Message = "Infusion berhasil dibuat"
	resp.Data = infusionResponse
	c.JSON(http.StatusOK, resp)
}

// GetAllInfusions implements InfusionHandlerInterface.
func (i *infusionHandler) GetAllInfusions(c *gin.Context) {
	var (
		ctx               = c.Request.Context()
		resp              = response.DefaultResponse{}
		infusionResponses = []response.InfusionHandlerResponse{}
	)

	infusions, err := i.infusionService.FindAll(ctx)
	if err != nil {
		log.Errorf("[InfusionHandler-1] GetAllInfusions: failed to get all infusions: %v", err)
		resp.Message = "Gagal mengambil semua infusi"
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	if len(infusions) == 0 {
		resp.Message = "Tidak ada infusi yang ditemukan"
		resp.Data = []response.InfusionHandlerResponse{}
		c.JSON(http.StatusOK, resp)
		return
	}

	for _, infusion := range infusions {
		infusionData := response.InfusionData{
			ID:           infusion.Infusion.ID,
			PatientID:    infusion.Infusion.PatientID,
			InfusionName: infusion.Infusion.InfusionName,
			PatientName:  infusion.Infusion.Patient.Name,
			StartTime:    infusion.Infusion.StartTime,
			EndTime:      infusion.Infusion.EndTime,
			StoppedAt:    infusion.Infusion.StoppedAt,
			Status:       infusion.Infusion.Status,
		}

		infusionResponses = append(infusionResponses, response.InfusionHandlerResponse{
			InfusionData:  infusionData,
			RemainingTime: infusion.RemainingTime,
			IsActive:      infusion.IsActive,
		})
	}

	resp.Message = "Infusi berhasil diambil"
	resp.Data = infusionResponses
	c.JSON(http.StatusOK, resp)
}

// GetInfusionByID implements InfusionHandlerInterface.
func (i *infusionHandler) GetInfusionByID(c *gin.Context) {
	var (
		req              = c.Param("id")
		ctx              = c.Request.Context()
		resp             = response.DefaultResponse{}
		infusionResponse = response.InfusionHandlerResponse{}
	)

	if req == "" {
		log.Errorf("[InfusionHandler-1] GetInfusionByID: missing required fields")
		resp.Message = "ID harus diisi"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	reqID, err := strconv.ParseInt(req, 10, 64)
	if err != nil {
		log.Errorf("[InfusionHandler-2] GetInfusionByID: invalid ID format: %v", err)
		resp.Message = "ID harus berupa angka"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	infusion, err := i.infusionService.FindByID(ctx, reqID)
	if err != nil {
		log.Errorf("[InfusionHandler-3] GetInfusionByID: failed to get infusion with id %d: %v", reqID, err)
		resp.Message = "Gagal mengambil infusi dengan ID tersebut"
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	infusionData := response.InfusionData{
		ID:           infusion.Infusion.ID,
		PatientID:    infusion.Infusion.PatientID,
		InfusionName: infusion.Infusion.InfusionName,
		PatientName:  infusion.Infusion.Patient.Name,
		StartTime:    infusion.Infusion.StartTime,
		EndTime:      infusion.Infusion.EndTime,
		StoppedAt:    infusion.Infusion.StoppedAt,
		Status:       infusion.Infusion.Status,
	}

	infusionResponse.InfusionData = infusionData
	infusionResponse.RemainingTime = infusion.RemainingTime
	infusionResponse.IsActive = infusion.IsActive

	resp.Message = "Infusi berhasil diambil"
	resp.Data = infusionResponse
	c.JSON(http.StatusOK, resp)
}

// GetInfusionsByPatientID implements InfusionHandlerInterface.
func (i *infusionHandler) GetInfusionsByPatientID(c *gin.Context) {
	var (
		req               = c.Param("patient_id")
		ctx               = c.Request.Context()
		resp              = response.DefaultResponse{}
		infusionResponses = []response.InfusionHandlerResponse{}
	)

	if req == "" {
		log.Errorf("[InfusionHandler-1] GetInfusionsByPatientID: missing required fields")
		resp.Message = "Patient ID harus diisi"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	reqID, err := strconv.ParseInt(req, 10, 64)
	if err != nil {
		log.Errorf("[InfusionHandler-2] GetInfusionsByPatientID: invalid patient ID format: %v", err)
		resp.Message = "Patient ID harus berupa angka"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	infusions, err := i.infusionService.FindByPatientID(ctx, reqID)
	if err != nil {
		log.Errorf("[InfusionHandler-3] GetInfusionsByPatientID: failed to get infusions for patient with id %d: %v", reqID, err)
		resp.Message = "Gagal mengambil infusi untuk pasien"
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	if len(infusions) == 0 {
		resp.Message = "Tidak ada infusi yang ditemukan untuk pasien"
		resp.Data = []response.InfusionHandlerResponse{}
		c.JSON(http.StatusOK, resp)
		return
	}

	for _, infusion := range infusions {
		infusionData := response.InfusionData{
			ID:           infusion.Infusion.ID,
			PatientID:    infusion.Infusion.PatientID,
			InfusionName: infusion.Infusion.InfusionName,
			PatientName:  infusion.Infusion.Patient.Name,
			StartTime:    infusion.Infusion.StartTime,
			EndTime:      infusion.Infusion.EndTime,
			StoppedAt:    infusion.Infusion.StoppedAt,
			Status:       infusion.Infusion.Status,
		}

		infusionResponses = append(infusionResponses, response.InfusionHandlerResponse{
			InfusionData:  infusionData,
			RemainingTime: infusion.RemainingTime,
			IsActive:      infusion.IsActive,
		})
	}

	resp.Message = "Infusi berhasil diambil"
	resp.Data = infusionResponses
	c.JSON(http.StatusOK, resp)
}

// GetOngoingInfusionsByPatientID implements InfusionHandlerInterface.
func (i *infusionHandler) GetOngoingInfusionsByPatientID(c *gin.Context) {
	var (
		req               = c.Param("patient_id")
		ctx               = c.Request.Context()
		resp              = response.DefaultResponse{}
		infusionResponses = response.InfusionHandlerResponse{}
	)

	if req == "" {
		log.Errorf("[InfusionHandler-1] GetOngoingInfusionsByPatientID: missing required fields")
		resp.Message = "Patient ID harus diisi"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	reqID, err := strconv.ParseInt(req, 10, 64)
	if err != nil {
		log.Errorf("[InfusionHandler-2] GetOngoingInfusionsByPatientID: invalid patient ID format: %v", err)
		resp.Message = "Patient ID harus berupa angka"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	infusion, err := i.infusionService.FindOngoingByPatientID(ctx, reqID)
	if infusion == nil {
		resp.Message = "Tidak ada infusi yang sedang berlangsung untuk pasien"
		c.JSON(http.StatusOK, resp)
		return
	}

	if err != nil {
		log.Errorf("[InfusionHandler-3] GetOngoingInfusionsByPatientID: failed to get ongoing infusions for patient with id %d: %v", reqID, err)
		resp.Message = "Gagal mengambil infusi yang sedang berlangsung untuk pasien"
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	infusionData := response.InfusionData{
		ID:           infusion.Infusion.ID,
		PatientID:    infusion.Infusion.PatientID,
		InfusionName: infusion.Infusion.InfusionName,
		PatientName:  infusion.Infusion.Patient.Name,
		StartTime:    infusion.Infusion.StartTime,
		EndTime:      infusion.Infusion.EndTime,
		StoppedAt:    infusion.Infusion.StoppedAt,
		Status:       infusion.Infusion.Status,
	}

	infusionResponses = response.InfusionHandlerResponse{
		InfusionData:  infusionData,
		RemainingTime: infusion.RemainingTime,
		IsActive:      infusion.IsActive,
	}

	resp.Message = "Infusi yang sedang berlangsung untuk pasien berhasil diambil"
	resp.Data = infusionResponses
	c.JSON(http.StatusOK, resp)
}

// StopInfusion implements InfusionHandlerInterface.
func (i *infusionHandler) StopInfusion(c *gin.Context) {
	var (
		req  = c.Param("id")
		ctx  = c.Request.Context()
		resp = response.DefaultResponse{}
	)

	if req == "" {
		log.Errorf("[InfusionHandler-1] StopInfusion: missing required fields")
		resp.Message = "Infusion ID harus diisi"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	reqID, err := strconv.ParseInt(req, 10, 64)
	if err != nil {
		log.Errorf("[InfusionHandler-2] StopInfusion: invalid infusion ID format: %v", err)
		resp.Message = "Infusion ID harus berupa angka"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	err = i.infusionService.StopInfusion(ctx, reqID)
	if err != nil {
		log.Errorf("[InfusionHandler-3] StopInfusion: failed to stop infusion with id %d: %v", reqID, err)
		resp.Message = "Gagal menghentikan infusi"
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	resp.Message = "Infusi berhasil dihentikan"
	c.JSON(http.StatusOK, resp)
}

func NewInfusionHandler(infusionService service.InfusionServiceInterface) InfusionHandlerInterface {
	return &infusionHandler{
		infusionService: infusionService,
	}
}
