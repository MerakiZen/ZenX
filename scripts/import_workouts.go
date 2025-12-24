package main

import (
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
	"strings"
	"time"
	"database/sql"
	"github.com/google/uuid"
	_ "github.com/jackc/pgx/v5/stdlib"
)

const (
	DB_URL  = "postgres://vaibhav:@localhost:5432/zenx?sslmode=disable"
	USER_ID = "c4742819-e9aa-4577-98a0-94264070d8af"
	CSV_PATH = "Hevy_workouts_log_100_weeks (1).csv"
)

type ExerciseMapping struct {
	Category  string
	Equipment string
}

func main() {
	db, err := sql.Open("pgx", DB_URL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatalf("Failed to ping database: %v", err)
	}

	fmt.Println("Connected to database.")

	file, err := os.Open(CSV_PATH)
	if err != nil {
		log.Fatalf("Failed to open CSV: %v", err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	header, err := reader.Read()
	if err != nil {
		log.Fatalf("Failed to read header: %v", err)
	}

	columns := make(map[string]int)
	for i, name := range header {
		columns[name] = i
	}

	exercises := make(map[string]string) // name -> id
	
	// Pre-load or seed exercises
	fmt.Println("Processing rows...")

	var currentWorkoutID string
	var currentWorkoutKey string // title + start_time
	var currentWorkoutExerciseID string
	var currentExerciseTitle string
	var exerciseOrder int

	count := 0
	for {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatalf("Failed to read record: %v", err)
		}

		title := record[columns["title"]]
		startTimeStr := record[columns["start_time"]]
		endTimeStr := record[columns["end_time"]]
		workoutDesc := record[columns["description"]]
		exerciseTitle := record[columns["exercise_title"]]
		setIndex := record[columns["set_index"]]
		setType := record[columns["set_type"]]
		weightLbs := record[columns["weight_lbs"]]
		reps := record[columns["reps"]]
		distanceMiles := record[columns["distance_miles"]]
		durationSeconds := record[columns["duration_seconds"]]
		muscleGroup := record[columns["muscle_group"]]

		// 1. Handle Workout
		workoutKey := title + "|" + startTimeStr
		if workoutKey != currentWorkoutKey {
			// New Workout
			startTime, _ := time.Parse("2 Jan 2006, 15:04", startTimeStr)
			// endTime, _ := time.Parse("2 Jan 2006, 15:04", endTimeStr)
			
			// Simple duration calculation if needed
			// dur := int(endTime.Sub(startTime).Minutes())

			err = db.QueryRow(`
				INSERT INTO "workout" ("userId", "name", "description", "date", "notes")
				VALUES ($1, $2, $3, $4, $5)
				RETURNING id`,
				USER_ID, title, workoutDesc, startTime, "").Scan(&currentWorkoutID)
			if err != nil {
				log.Fatalf("Failed to insert workout: %v", err)
			}
			currentWorkoutKey = workoutKey
			exerciseOrder = 0
			currentExerciseTitle = ""
		}

		// 2. Handle Exercise Definition
		exerciseID, exists := exercises[exerciseTitle]
		if !exists {
			// Get or Create Exercise
			err = db.QueryRow("SELECT id FROM exercise WHERE name = $1", exerciseTitle).Scan(&exerciseID)
			if err != nil {
				// Create Exercise
				category := mapMuscleToCategory(muscleGroup)
				equipment := mapTitleToEquipment(exerciseTitle)
				
				err = db.QueryRow(`
					INSERT INTO exercise (name, description, category, "muscleGroup", equipment, "isCustom")
					VALUES ($1, $2, $3, $4, $5, $6)
					RETURNING id`,
					exerciseTitle, "", category, muscleGroup, equipment, false).Scan(&exerciseID)
				if err != nil {
					log.Fatalf("Failed to insert exercise %s: %v", exerciseTitle, err)
				}
			}
			exercises[exerciseTitle] = exerciseID
		}

		// 3. Handle Workout Exercise
		if exerciseTitle != currentExerciseTitle {
			exerciseOrder++
			err = db.QueryRow(`
				INSERT INTO "workout_exercise" ("workoutId", "exerciseId", "order")
				VALUES ($1, $2, $3)
				RETURNING id`,
				currentWorkoutID, exerciseID, exerciseOrder).Scan(&currentWorkoutExerciseID)
			if err != nil {
				log.Fatalf("Failed to insert workout exercise: %v", err)
			}
			currentExerciseTitle = exerciseTitle
		}

		// 4. Handle Set
		// Note: The database uses 'weight' as double precision.
		// If CSV weight is empty, we use 0 or null.
		var weightVal sql.NullFloat64
		if weightLbs != "" {
			var w float64
			fmt.Sscanf(weightLbs, "%f", &w)
			weightVal = sql.NullFloat64{Float64: w, Valid: true}
		}

		var repsVal sql.NullInt32
		if reps != "" {
			var r int32
			fmt.Sscanf(reps, "%d", &r)
			repsVal = sql.NullInt32{Int32: r, Valid: true}
		}

		var durVal sql.NullInt32
		if durationSeconds != "" {
			var d int32
			fmt.Sscanf(durationSeconds, "%d", &d)
			durVal = sql.NullInt32{Int32: d, Valid: true}
		}

		var distVal sql.NullFloat64
		if distanceMiles != "" {
			var d float64
			fmt.Sscanf(distanceMiles, "%f", &d)
			distVal = sql.NullFloat64{Float64: d, Valid: true}
		}

		var setIdxInt int
		fmt.Sscanf(setIndex, "%d", &setIdxInt)

		_, err = db.Exec(`
			INSERT INTO "set" ("workoutExerciseId", "setNumber", "reps", "weight", "duration", "distance", "completed")
			VALUES ($1, $2, $3, $4, $5, $6, $7)`,
			currentWorkoutExerciseID, setIdxInt+1, repsVal, weightVal, durVal, distVal, true)
		if err != nil {
			log.Fatalf("Failed to insert set: %v", err)
		}

		count++
		if count % 100 == 0 {
			fmt.Printf("Processed %d sets...\n", count)
		}
	}

	fmt.Printf("Finished importing %d sets!\n", count)
}

func mapMuscleToCategory(muscle string) string {
	m := strings.ToLower(muscle)
	switch {
	case strings.Contains(m, "chest"):
		return "CHEST"
	case strings.Contains(m, "back") || strings.Contains(m, "lats"):
		return "BACK"
	case strings.Contains(m, "legs") || strings.Contains(m, "quad") || strings.Contains(m, "hamstring") || strings.Contains(m, "calf") || strings.Contains(m, "glute") || strings.Contains(m, "adductor") || strings.Contains(m, "abductor"):
		return "LEGS"
	case strings.Contains(m, "shoulder"):
		return "SHOULDERS"
	case strings.Contains(m, "tricep") || strings.Contains(m, "bicep") || strings.Contains(m, "arm") || strings.Contains(m, "forearm"):
		return "ARMS"
	case strings.Contains(m, "abdominal") || strings.Contains(m, "abs") || strings.Contains(m, "core") || strings.Contains(m, "oblique"):
		return "CORE"
	default:
		return "CORE" // Default to CORE if unknown, or maybe we should have OTHER? 
		// Actually let's check the enums again. CHEST, BACK, LEGS, SHOULDERS, ARMS, CORE.
	}
}

func mapTitleToEquipment(title string) string {
	t := strings.ToLower(title)
	switch {
	case strings.Contains(t, "barbell"):
		return "BARBELL"
	case strings.Contains(t, "dumbbell"):
		return "DUMBBELL"
	case strings.Contains(t, "machine"):
		return "MACHINE"
	case strings.Contains(t, "cable"):
		return "CABLE"
	case strings.Contains(t, "bodyweight") || strings.Contains(t, "box jump") || strings.Contains(t, "push up") || strings.Contains(t, "chin up") || strings.Contains(t, "dip") || strings.Contains(t, "plank") || strings.Contains(t, "yoga"):
		return "BODYWEIGHT"
	default:
		return "OTHER"
	}
}
