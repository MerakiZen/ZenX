package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"strings"

	_ "github.com/jackc/pgx/v5/stdlib"
)

// Exercise data structure
type ExerciseData struct {
	Name                 string
	Description          string
	Category             string
	PrimaryMuscleGroup   string
	SecondaryMuscleGroup []string
	EquipmentRequired    string
	DifficultyLevel      string
}

// Comprehensive exercise database
var exercises = []ExerciseData{
	// CHEST
	{"Bench Press", "Classic chest exercise using barbell", "chest", "Chest", []string{"Triceps", "Shoulders"}, "Barbell", "Intermediate"},
	{"Incline Bench Press", "Upper chest focus", "chest", "Upper Chest", []string{"Shoulders", "Triceps"}, "Barbell", "Intermediate"},
	{"Decline Bench Press", "Lower chest focus", "chest", "Lower Chest", []string{"Triceps"}, "Barbell", "Intermediate"},
	{"Dumbbell Press", "Chest exercise with dumbbells", "chest", "Chest", []string{"Shoulders", "Triceps"}, "Dumbbell", "Intermediate"},
	{"Incline Dumbbell Press", "Upper chest with dumbbells", "chest", "Upper Chest", []string{"Shoulders"}, "Dumbbell", "Intermediate"},
	{"Dumbbell Flyes", "Isolation chest exercise", "chest", "Chest", []string{}, "Dumbbell", "Beginner"},
	{"Cable Flyes", "Chest isolation with cables", "chest", "Chest", []string{}, "Cable Machine", "Beginner"},
	{"Push-ups", "Bodyweight chest exercise", "chest", "Chest", []string{"Triceps", "Shoulders", "Core"}, "Bodyweight", "Beginner"},
	{"Diamond Push-ups", "Triceps and chest focus", "chest", "Chest", []string{"Triceps"}, "Bodyweight", "Intermediate"},
	{"Chest Dips", "Advanced chest and triceps", "chest", "Chest", []string{"Triceps", "Shoulders"}, "Bodyweight", "Advanced"},
	{"Pec Deck", "Machine chest isolation", "chest", "Chest", []string{}, "Machine", "Beginner"},
	{"Cable Crossover", "Chest exercise with cables", "chest", "Chest", []string{}, "Cable Machine", "Intermediate"},

	// BACK
	{"Deadlift", "Full body compound movement", "back", "Back", []string{"Hamstrings", "Glutes", "Core"}, "Barbell", "Advanced"},
	{"Barbell Row", "Back width and thickness", "back", "Lats", []string{"Biceps", "Rhomboids"}, "Barbell", "Intermediate"},
	{"T-Bar Row", "Back thickness builder", "back", "Lats", []string{"Rhomboids", "Biceps"}, "Barbell", "Intermediate"},
	{"Dumbbell Row", "Unilateral back exercise", "back", "Lats", []string{"Biceps", "Rhomboids"}, "Dumbbell", "Intermediate"},
	{"Pull-ups", "Bodyweight back exercise", "back", "Lats", []string{"Biceps", "Rhomboids"}, "Bodyweight", "Intermediate"},
	{"Chin-ups", "Biceps and back focus", "back", "Lats", []string{"Biceps"}, "Bodyweight", "Intermediate"},
	{"Lat Pulldown", "Machine back exercise", "back", "Lats", []string{"Biceps"}, "Cable Machine", "Beginner"},
	{"Seated Cable Row", "Back thickness with cables", "back", "Lats", []string{"Rhomboids", "Biceps"}, "Cable Machine", "Beginner"},
	{"Wide Grip Pulldown", "Back width focus", "back", "Lats", []string{"Biceps"}, "Cable Machine", "Beginner"},
	{"Close Grip Pulldown", "Back thickness focus", "back", "Lats", []string{"Biceps"}, "Cable Machine", "Beginner"},
	{"Face Pull", "Rear delts and upper back", "back", "Rear Delts", []string{"Rhomboids"}, "Cable Machine", "Beginner"},
	{"Shrugs", "Trap development", "back", "Traps", []string{}, "Barbell", "Beginner"},
	{"Dumbbell Shrugs", "Trap exercise with dumbbells", "back", "Traps", []string{}, "Dumbbell", "Beginner"},
	{"Hyperextensions", "Lower back strength", "back", "Lower Back", []string{"Glutes"}, "Bodyweight", "Beginner"},
	{"Good Mornings", "Posterior chain exercise", "back", "Lower Back", []string{"Hamstrings", "Glutes"}, "Barbell", "Advanced"},

	// LEGS
	{"Squat", "King of leg exercises", "legs", "Quadriceps", []string{"Glutes", "Hamstrings", "Core"}, "Barbell", "Intermediate"},
	{"Front Squat", "Quadriceps and core focus", "legs", "Quadriceps", []string{"Core", "Glutes"}, "Barbell", "Advanced"},
	{"Leg Press", "Machine quadriceps exercise", "legs", "Quadriceps", []string{"Glutes"}, "Machine", "Beginner"},
	{"Leg Extension", "Quadriceps isolation", "legs", "Quadriceps", []string{}, "Machine", "Beginner"},
	{"Romanian Deadlift", "Hamstring and glute focus", "legs", "Hamstrings", []string{"Glutes", "Lower Back"}, "Barbell", "Intermediate"},
	{"Leg Curl", "Hamstring isolation", "legs", "Hamstrings", []string{}, "Machine", "Beginner"},
	{"Lunges", "Unilateral leg exercise", "legs", "Quadriceps", []string{"Glutes", "Hamstrings"}, "Bodyweight", "Beginner"},
	{"Walking Lunges", "Dynamic leg exercise", "legs", "Quadriceps", []string{"Glutes", "Hamstrings"}, "Bodyweight", "Intermediate"},
	{"Bulgarian Split Squat", "Unilateral quadriceps", "legs", "Quadriceps", []string{"Glutes"}, "Dumbbell", "Intermediate"},
	{"Calf Raise", "Calf development", "legs", "Calves", []string{}, "Machine", "Beginner"},
	{"Standing Calf Raise", "Calf exercise standing", "legs", "Calves", []string{}, "Machine", "Beginner"},
	{"Seated Calf Raise", "Calf exercise seated", "legs", "Calves", []string{}, "Machine", "Beginner"},
	{"Hack Squat", "Machine squat variation", "legs", "Quadriceps", []string{"Glutes"}, "Machine", "Intermediate"},
	{"Goblet Squat", "Front-loaded squat", "legs", "Quadriceps", []string{"Glutes", "Core"}, "Dumbbell", "Beginner"},
	{"Step-ups", "Unilateral leg exercise", "legs", "Quadriceps", []string{"Glutes"}, "Dumbbell", "Intermediate"},

	// SHOULDERS
	{"Overhead Press", "Shoulder strength builder", "shoulders", "Shoulders", []string{"Triceps", "Core"}, "Barbell", "Intermediate"},
	{"Dumbbell Press", "Shoulder exercise with dumbbells", "shoulders", "Shoulders", []string{"Triceps"}, "Dumbbell", "Intermediate"},
	{"Lateral Raise", "Side deltoid isolation", "shoulders", "Side Delts", []string{}, "Dumbbell", "Beginner"},
	{"Front Raise", "Front deltoid isolation", "shoulders", "Front Delts", []string{}, "Dumbbell", "Beginner"},
	{"Rear Delt Fly", "Rear deltoid isolation", "shoulders", "Rear Delts", []string{"Rhomboids"}, "Dumbbell", "Beginner"},
	{"Cable Lateral Raise", "Side delts with cables", "shoulders", "Side Delts", []string{}, "Cable Machine", "Beginner"},
	{"Arnold Press", "Rotating shoulder press", "shoulders", "Shoulders", []string{"Triceps"}, "Dumbbell", "Intermediate"},
	{"Upright Row", "Upper trap and delt exercise", "shoulders", "Traps", []string{"Side Delts"}, "Barbell", "Intermediate"},
	{"Pike Push-up", "Bodyweight shoulder exercise", "shoulders", "Shoulders", []string{"Triceps"}, "Bodyweight", "Intermediate"},
	{"Handstand Push-up", "Advanced shoulder exercise", "shoulders", "Shoulders", []string{"Triceps", "Core"}, "Bodyweight", "Advanced"},

	// ARMS - BICEPS
	{"Barbell Curl", "Classic bicep exercise", "arms", "Biceps", []string{}, "Barbell", "Beginner"},
	{"Dumbbell Curl", "Bicep exercise with dumbbells", "arms", "Biceps", []string{}, "Dumbbell", "Beginner"},
	{"Hammer Curl", "Brachialis and bicep focus", "arms", "Biceps", []string{"Forearms"}, "Dumbbell", "Beginner"},
	{"Cable Curl", "Bicep exercise with cables", "arms", "Biceps", []string{}, "Cable Machine", "Beginner"},
	{"Preacher Curl", "Bicep isolation", "arms", "Biceps", []string{}, "Barbell", "Intermediate"},
	{"Concentration Curl", "Bicep isolation seated", "arms", "Biceps", []string{}, "Dumbbell", "Beginner"},
	{"21s", "Bicep volume technique", "arms", "Biceps", []string{}, "Barbell", "Intermediate"},
	{"Cable Hammer Curl", "Brachialis with cables", "arms", "Biceps", []string{"Forearms"}, "Cable Machine", "Beginner"},

	// ARMS - TRICEPS
	{"Close Grip Bench Press", "Triceps and chest", "arms", "Triceps", []string{"Chest"}, "Barbell", "Intermediate"},
	{"Tricep Dips", "Bodyweight tricep exercise", "arms", "Triceps", []string{"Shoulders"}, "Bodyweight", "Intermediate"},
	{"Overhead Extension", "Tricep isolation", "arms", "Triceps", []string{}, "Dumbbell", "Beginner"},
	{"Cable Tricep Extension", "Tricep exercise with cables", "arms", "Triceps", []string{}, "Cable Machine", "Beginner"},
	{"Tricep Kickback", "Tricep isolation", "arms", "Triceps", []string{}, "Dumbbell", "Beginner"},
	{"Skull Crushers", "Tricep isolation lying", "arms", "Triceps", []string{}, "Barbell", "Intermediate"},
	{"Diamond Push-ups", "Tricep focused push-ups", "arms", "Triceps", []string{"Chest"}, "Bodyweight", "Intermediate"},
	{"Cable Overhead Extension", "Tricep exercise overhead", "arms", "Triceps", []string{}, "Cable Machine", "Beginner"},

	// ARMS - FOREARMS
	{"Wrist Curl", "Forearm flexor exercise", "arms", "Forearms", []string{}, "Barbell", "Beginner"},
	{"Reverse Wrist Curl", "Forearm extensor exercise", "arms", "Forearms", []string{}, "Barbell", "Beginner"},
	{"Farmer's Walk", "Grip and forearm strength", "arms", "Forearms", []string{"Traps", "Core"}, "Dumbbell", "Intermediate"},
	{"Plate Pinch", "Grip strength exercise", "arms", "Forearms", []string{}, "Other", "Beginner"},

	// CORE
	{"Plank", "Core stability exercise", "core", "Core", []string{}, "Bodyweight", "Beginner"},
	{"Side Plank", "Oblique and core strength", "core", "Obliques", []string{"Core"}, "Bodyweight", "Beginner"},
	{"Crunches", "Abdominal exercise", "core", "Abs", []string{}, "Bodyweight", "Beginner"},
	{"Sit-ups", "Abdominal exercise", "core", "Abs", []string{}, "Bodyweight", "Beginner"},
	{"Russian Twists", "Oblique and core exercise", "core", "Obliques", []string{"Abs"}, "Bodyweight", "Beginner"},
	{"Leg Raises", "Lower ab exercise", "core", "Abs", []string{}, "Bodyweight", "Beginner"},
	{"Hanging Leg Raises", "Advanced core exercise", "core", "Abs", []string{"Hip Flexors"}, "Bodyweight", "Advanced"},
	{"Ab Wheel Rollout", "Core strength exercise", "core", "Abs", []string{}, "Other", "Intermediate"},
	{"Mountain Climbers", "Cardio and core", "core", "Core", []string{}, "Bodyweight", "Beginner"},
	{"Dead Bug", "Core stability exercise", "core", "Core", []string{}, "Bodyweight", "Beginner"},
	{"Bird Dog", "Core and back stability", "core", "Core", []string{"Lower Back"}, "Bodyweight", "Beginner"},
	{"L-Sit", "Advanced core strength", "core", "Abs", []string{"Hip Flexors"}, "Bodyweight", "Advanced"},
	{"Dragon Flag", "Advanced core exercise", "core", "Abs", []string{}, "Bodyweight", "Advanced"},

	// CARDIO
	{"Running", "Cardiovascular exercise", "cardio", "Cardio", []string{}, "Other", "Beginner"},
	{"Cycling", "Low impact cardio", "cardio", "Cardio", []string{"Legs"}, "Other", "Beginner"},
	{"Rowing", "Full body cardio", "cardio", "Cardio", []string{"Back", "Legs"}, "Machine", "Intermediate"},
	{"Jump Rope", "High intensity cardio", "cardio", "Cardio", []string{"Calves"}, "Other", "Beginner"},
	{"Burpees", "Full body cardio exercise", "cardio", "Cardio", []string{"Legs", "Core"}, "Bodyweight", "Intermediate"},
	{"High Knees", "Cardio and leg exercise", "cardio", "Cardio", []string{"Calves"}, "Bodyweight", "Beginner"},
	{"Jumping Jacks", "Full body cardio", "cardio", "Cardio", []string{}, "Bodyweight", "Beginner"},
}

func main() {
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		dbURL = "postgres://zenx:zenx@localhost:5432/zenx_exercise?sslmode=disable"
	}

	db, err := sql.Open("pgx", dbURL)
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer db.Close()

	ctx := context.Background()

	// Create categories
	categories := map[string]string{
		"chest":     "Chest",
		"back":      "Back",
		"legs":      "Legs",
		"shoulders": "Shoulders",
		"arms":      "Arms",
		"core":      "Core",
		"cardio":    "Cardio",
	}

	categoryIDs := make(map[string]string)

	for slug, name := range categories {
		var id string
		err := db.QueryRowContext(ctx,
			"INSERT INTO exercise_categories (slug, name) VALUES ($1, $2) ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id",
			slug, name).Scan(&id)
		if err != nil {
			log.Fatalf("Failed to create category %s: %v", slug, err)
		}
		categoryIDs[slug] = id
		fmt.Printf("Created category: %s (%s)\n", name, id)
	}

	// Insert exercises
	insertedCount := 0
	for _, ex := range exercises {
		categoryID := categoryIDs[strings.ToLower(ex.Category)]
		
		// Check if exercise already exists
		var exists bool
		err := db.QueryRowContext(ctx,
			"SELECT EXISTS(SELECT 1 FROM exercises WHERE name = $1)",
			ex.Name).Scan(&exists)
		if err != nil {
			log.Printf("Failed to check existence for %s: %v", ex.Name, err)
			continue
		}
		
		if exists {
			fmt.Printf("Skipped (already exists): %s\n", ex.Name)
			continue
		}
		
		_, err = db.ExecContext(ctx,
			`INSERT INTO exercises (name, description, category_id, primary_muscle_group, secondary_muscle_groups, equipment_required, difficulty_level, is_custom)
			 VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
			ex.Name,
			ex.Description,
			categoryID,
			ex.PrimaryMuscleGroup,
			ex.SecondaryMuscleGroup,
			ex.EquipmentRequired,
			ex.DifficultyLevel,
			false,
		)
		if err != nil {
			log.Printf("Failed to insert %s: %v", ex.Name, err)
			continue
		}
		fmt.Printf("Inserted: %s\n", ex.Name)
		insertedCount++
	}

	fmt.Printf("\nSuccessfully seeded %d exercises!\n", len(exercises))
}

