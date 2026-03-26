package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
	"github.com/labstack/gommon/log"
)

type App struct {
	AppPort string `env:"APP_PORT"`
	AppEnv  string `env:"APP_ENV"`
}

type Database struct {
	Port               string `env:"PORT"`
	Host               string `env:"HOST"`
	User               string `env:"USER"`
	Password           string `env:"PASSWORD"`
	DBName             string `env:"DB_NAME"`
	MaxOpenConnections int    `env:"MAX_OPEN_CONNECTIONS"`
	MaxIdleConnections int    `env:"MAX_IDLE_CONNECTIONS"`
}

type Config struct {
	App      App
	Database Database
}

func NewConfig() (*Config, error) {
	err := godotenv.Load()
	if err != nil {
		log.Warnf("No .env file found, using environment variables: %v", err)
	}

	return &Config{
		App: App{
			AppPort: getEnv("APP_PORT", "8080"),
			AppEnv:  getEnv("APP_ENV", "development"),
		},
		Database: Database{
			Port:               getEnv("DATABASE_PORT", "5432"),
			Host:               getEnv("DATABASE_HOST", "localhost"),
			User:               getEnv("DATABASE_USER", "postgres"),
			Password:           getEnv("DATABASE_PASSWORD", "postgres"),
			DBName:             getEnv("DATABASE_NAME", "health_reminder"),
			MaxOpenConnections: getEnvAsInt("DATABASE_MAX_OPEN_CONNECTIONS", 10),
			MaxIdleConnections: getEnvAsInt("DATABASE_MAX_IDLE_CONNECTIONS", 20),
		},
	}, nil
}

func getEnv(key, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		log.Infof("Environment variable %s found: %s", key, value)
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	if valueStr, exists := os.LookupEnv(key); exists {
		var value int
		_, err := fmt.Sscanf(valueStr, "%d", &value)
		if err != nil {
			log.Errorf("Error parsing environment variable %s: %v", key, err)
			return defaultValue
		}
		log.Infof("Environment variable %s found: %d", key, value)
		return value
	}
	return defaultValue
}
