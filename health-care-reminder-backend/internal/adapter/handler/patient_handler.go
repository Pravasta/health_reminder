package handler

import (
	"errors"
	"health-care-reminder/internal/adapter/dto/request"
	"health-care-reminder/internal/adapter/dto/response"
	"health-care-reminder/internal/adapter/message"
	"health-care-reminder/internal/core/domain/entity"
	"health-care-reminder/internal/core/service"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/labstack/gommon/log"
)

type PatientHandlerInterface interface {
	CreatePatient(c *gin.Context)
	GetAllPatients(c *gin.Context)
	GetPatientByID(c *gin.Context)
	DeletePatient(c *gin.Context)
}

type patientHandler struct {
	patientService service.PatientServiceInterface
}

// CreatePatient implements PatientHandlerInterface.
func (p *patientHandler) CreatePatient(c *gin.Context) {
	var (
		req  = request.CreatePatientRequest{}
		resp = response.DefaultResponse{}
		ctx  = c.Request.Context()
	)

	if err := c.ShouldBindJSON(&req); err != nil {
		log.Errorf("[PatientHandler-1] CreatePatient: failed to bind request body: %v", err)
		resp.Message = "Data request tidak valid"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	// validate request body
	if req.Name == "" || req.Code == "" {
		log.Errorf("[PatientHandler-2] CreatePatient: missing required fields")
		resp.Message = "Name dan code harus diisi"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	if req.Gender == "" {
		log.Errorf("[PatientHandler-3] CreatePatient: missing required fields")
		resp.Message = "Jenis Kelamin harus diisi"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	patientEntity := entity.PatientEntity{
		Name:   req.Name,
		Code:   req.Code,
		Gender: req.Gender,
	}

	if err := p.patientService.Create(ctx, &patientEntity); err != nil {
		log.Errorf("[PatientHandler-4] CreatePatient: failed to create patient: %v", err)
		if errors.Is(err, message.ErrDuplicateCode) {
			resp.Message = "Kode pasien sudah ada"
			c.JSON(http.StatusBadRequest, resp)
			return
		}

		resp.Message = "Gagal membuat pasien"
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	resp.Message = "Pasien berhasil dibuat"
	c.JSON(http.StatusCreated, resp)
}

// DeletePatient implements PatientHandlerInterface.
func (p *patientHandler) DeletePatient(c *gin.Context) {
	var (
		req  = c.Param("id")
		resp = response.DefaultResponse{}
		ctx  = c.Request.Context()
	)

	// validate request body and make sure to int64
	if req == "" {
		log.Errorf("[PatientHandler-1] DeletePatient: missing required fields")
		resp.Message = "ID harus diisi"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	reqID, err := strconv.ParseInt(req, 10, 64)

	if err != nil {
		log.Errorf("[PatientHandler-2] DeletePatient: invalid id format: %v", err)
		resp.Message = "ID harus berupa angka"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	if err := p.patientService.Delete(ctx, reqID); err != nil {
		log.Errorf("[PatientHandler-3] DeletePatient: failed to delete patient with id %d: %v", reqID, err)
		resp.Message = "Gagal menghapus pasien"
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	resp.Message = "Pasien berhasil dihapus"
	c.JSON(http.StatusOK, resp)
}

// GetAllPatients implements PatientHandlerInterface.
func (p *patientHandler) GetAllPatients(c *gin.Context) {
	var (
		resp            = response.DefaultResponse{}
		ctx             = c.Request.Context()
		patientResponse = []response.PatientResponse{}
	)

	patients, err := p.patientService.FindAll(ctx)
	if err != nil {
		log.Errorf("[PatientHandler-1] GetAllPatients: failed to find patients: %v", err)
		resp.Message = "Gagal menemukan pasien"
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	for _, patient := range patients {
		patientResponse = append(patientResponse, response.PatientResponse{
			ID:        patient.ID,
			Name:      patient.Name,
			Code:      patient.Code,
			Gender:    patient.Gender,
			Status:    patient.Status,
			Tpm:       patient.Tpm,
			StartTime: patient.StartTime,
			EndTime:   patient.EndTime,
		})
	}

	resp.Message = "Daftar Pasien ditemukan"
	resp.Data = patientResponse
	c.JSON(http.StatusOK, resp)
}

// GetPatientByID implements PatientHandlerInterface.
func (p *patientHandler) GetPatientByID(c *gin.Context) {
	var (
		req             = c.Param("id")
		resp            = response.DefaultResponse{}
		ctx             = c.Request.Context()
		patientResponse = response.PatientResponse{}
	)

	if req == "" {
		log.Errorf("[PatientHandler-1] GetPatientByID: missing required fields")
		resp.Message = "ID harus diisi"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	reqID, err := strconv.ParseInt(req, 10, 64)
	if err != nil {
		log.Errorf("[PatientHandler-2] GetPatientByID: invalid id format: %v", err)
		resp.Message = "ID harus berupa angka"
		c.JSON(http.StatusBadRequest, resp)
		return
	}

	patient, err := p.patientService.FindByID(ctx, reqID)
	if err != nil {
		log.Errorf("[PatientHandler-3] GetPatientByID: failed to find patient with id %d: %v", reqID, err)
		resp.Message = "Gagal menemukan pasien"
		c.JSON(http.StatusInternalServerError, resp)
		return
	}

	patientResponse = response.PatientResponse{
		ID:     patient.ID,
		Name:   patient.Name,
		Code:   patient.Code,
		Gender: patient.Gender,
		Status: patient.Status,
	}

	resp.Message = "Pasien ditemukan"
	resp.Data = patientResponse
	c.JSON(http.StatusOK, resp)
}

func NewPatientHandler(patientService service.PatientServiceInterface) PatientHandlerInterface {
	return &patientHandler{
		patientService: patientService,
	}
}
