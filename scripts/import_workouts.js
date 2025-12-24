const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const DB_HOST = process.env.DB_HOST || "localhost";
const DB_BASE_URL = `postgres://zenx:zenx@${DB_HOST}:5432`;
const USER_ID = "38c76f10-20ba-44c9-be55-734070e4fb3a";
const CSV_PATH = path.join(__dirname, '..', 'Hevy_workouts_log_100_weeks (1).csv');

async function createDatabase() {
  console.log(`Checking if database 'zenx' exists on ${DB_HOST}...`);
  const client = new Client({ connectionString: `${DB_BASE_URL}/postgres` });
  await client.connect();

  try {
    const res = await client.query("SELECT 1 FROM pg_database WHERE datname = 'zenx'");
    if (res.rows.length === 0) {
      console.log("Database 'zenx' does not exist. Creating...");
      await client.query("CREATE DATABASE zenx");
      console.log("Database 'zenx' created.");
    } else {
      console.log("Database 'zenx' already exists.");
    }
  } finally {
    await client.end();
  }
}

async function createTables(client) {
  console.log("Creating tables...");
  await client.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";');

  await client.query(`CREATE TABLE IF NOT EXISTS "workout" (
        "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "userId" UUID NOT NULL,
        "name" TEXT NOT NULL,
        "description" TEXT,
        "date" TIMESTAMPTZ,
        "notes" TEXT,
        "likes" TEXT[] DEFAULT '{}',
        "created_at" TIMESTAMPTZ DEFAULT NOW()
    );`);

  await client.query(`CREATE TABLE IF NOT EXISTS "exercise" (
        "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "name" TEXT NOT NULL,
        "description" TEXT,
        "category" TEXT,
        "muscleGroup" TEXT,
        "equipment" TEXT,
        "isCustom" BOOLEAN DEFAULT FALSE,
        "created_at" TIMESTAMPTZ DEFAULT NOW()
    );`);

  await client.query(`CREATE TABLE IF NOT EXISTS "workout_exercise" (
        "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "workoutId" UUID REFERENCES "workout"("id") ON DELETE CASCADE,
        "exerciseId" UUID REFERENCES "exercise"("id"),
        "order" INT,
        "notes" TEXT,
        "created_at" TIMESTAMPTZ DEFAULT NOW()
    );`);

  await client.query(`CREATE TABLE IF NOT EXISTS "set" (
        "id" UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        "workoutExerciseId" UUID REFERENCES "workout_exercise"("id") ON DELETE CASCADE,
        "setNumber" INT,
        "reps" INT,
        "weight" FLOAT,
        "duration" INT,
        "distance" FLOAT,
        "completed" BOOLEAN DEFAULT TRUE,
        "created_at" TIMESTAMPTZ DEFAULT NOW()
    );`);
  console.log("Tables created.");
}

function parseCSV(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');
  const header = lines[0].split(',');
  const result = [];

  for (let i = 1; i < lines.length; i++) {
    if (!lines[i]) continue;

    // Handle cases where commas are inside quotes (like start_time)
    const row = [];
    let current = '';
    let inQuotes = false;
    for (let char of lines[i]) {
      if (char === '"') {
        inQuotes = !inQuotes;
      } else if (char === ',' && !inQuotes) {
        row.push(current);
        current = '';
      } else {
        current += char;
      }
    }
    row.push(current);

    const obj = {};
    header.forEach((h, index) => {
      obj[h.trim()] = row[index] ? row[index].trim() : '';
    });
    result.push(obj);
  }
  return result;
}

function mapMuscleToCategory(muscle) {
  const m = (muscle || '').toLowerCase();
  if (m.includes('chest')) return 'CHEST';
  if (m.includes('back') || m.includes('lats')) return 'BACK';
  if (m.includes('legs') || m.includes('quad') || m.includes('hamstring') || m.includes('calf') || m.includes('glute') || m.includes('adductor') || m.includes('abductor')) return 'LEGS';
  if (m.includes('shoulder')) return 'SHOULDERS';
  if (m.includes('tricep') || m.includes('bicep') || m.includes('arm') || m.includes('forearm')) return 'ARMS';
  if (m.includes('abdominal') || m.includes('abs') || m.includes('core') || m.includes('oblique')) return 'CORE';
  return 'CORE';
}

function mapTitleToEquipment(title) {
  const t = (title || '').toLowerCase();
  if (t.includes('barbell')) return 'BARBELL';
  if (t.includes('dumbbell')) return 'DUMBBELL';
  if (t.includes('machine')) return 'MACHINE';
  if (t.includes('cable')) return 'CABLE';
  if (t.includes('bodyweight') || t.includes('box jump') || t.includes('push up') || t.includes('chin up') || t.includes('dip') || t.includes('plank') || t.includes('yoga')) return 'BODYWEIGHT';
  return 'OTHER';
}

async function run() {
  await createDatabase();

  const client = new Client({
    connectionString: `${DB_BASE_URL}/zenx`,
  });

  await client.connect();
  console.log('Connected to zenx database.');

  await createTables(client);

  // Check if data already exists
  const checkRes = await client.query('SELECT count(*) FROM "workout"');
  if (parseInt(checkRes.rows[0].count) > 0) {
    console.log(`Database already has ${checkRes.rows[0].count} workouts. Skipping import.`);
    await client.query('TRUNCATE "workout", "exercise", "workout_exercise", "set" CASCADE');
    console.log('Truncated existing data for fresh import.');
  }

  const data = parseCSV(CSV_PATH);
  console.log(`Parsed ${data.length} rows from CSV.`);

  const exerciseMap = new Map(); // name -> id

  let currentWorkoutID = null;
  let currentWorkoutKey = null;
  let currentWorkoutExerciseID = null;
  let currentExerciseTitle = null;
  let exerciseOrder = 0;

  for (let i = 0; i < data.length; i++) {
    const row = data[i];

    // 1. Workout
    const workoutKey = row.title + '|' + row.start_time;
    if (workoutKey !== currentWorkoutKey) {
      // New Workout
      const date = new Date(row.start_time);

      const res = await client.query(
        'INSERT INTO "workout" ("userId", "name", "description", "date", "notes", "likes") VALUES ($1, $2, $3, $4, $5, $6) RETURNING id',
        [USER_ID, row.title, row.description || '', date, '', []]
      );
      currentWorkoutID = res.rows[0].id;
      currentWorkoutKey = workoutKey;
      exerciseOrder = 0;
      currentExerciseTitle = null;
      // console.log(`Started workout: ${row.title} (${date.toISOString()})`);
    }

    // 2. Exercise
    let exerciseID = exerciseMap.get(row.exercise_title);
    if (!exerciseID) {
      // Check if exists in DB
      const exRes = await client.query('SELECT id FROM "exercise" WHERE name = $1', [row.exercise_title]);
      if (exRes.rows.length > 0) {
        exerciseID = exRes.rows[0].id;
      } else {
        // Create Exercise
        const category = mapMuscleToCategory(row.muscle_group);
        const equipment = mapTitleToEquipment(row.exercise_title);
        const newExRes = await client.query(
          'INSERT INTO "exercise" ("name", "description", "category", "muscleGroup", "equipment", "isCustom") VALUES ($1, $2, $3, $4, $5, $6) RETURNING id',
          [row.exercise_title, '', category, row.muscle_group, equipment, false]
        );
        exerciseID = newExRes.rows[0].id;
      }
      exerciseMap.set(row.exercise_title, exerciseID);
    }

    // 3. Workout Exercise
    if (row.exercise_title !== currentExerciseTitle) {
      exerciseOrder++;
      const weRes = await client.query(
        'INSERT INTO "workout_exercise" ("workoutId", "exerciseId", "order", "notes") VALUES ($1, $2, $3, $4) RETURNING id',
        [currentWorkoutID, exerciseID, exerciseOrder, '']
      );
      currentWorkoutExerciseID = weRes.rows[0].id;
      currentExerciseTitle = row.exercise_title;
    }

    // 4. Set
    const weightVal = row.weight_lbs ? parseFloat(row.weight_lbs) : null;
    const repsVal = row.reps ? parseInt(row.reps) : null;
    const durVal = row.duration_seconds ? parseInt(row.duration_seconds) : null;
    const distVal = row.distance_miles ? parseFloat(row.distance_miles) : null;
    const setNum = parseInt(row.set_index) + 1;

    await client.query(
      'INSERT INTO "set" ("workoutExerciseId", "setNumber", "reps", "weight", "duration", "distance", "completed") VALUES ($1, $2, $3, $4, $5, $6, $7)',
      [currentWorkoutExerciseID, setNum, repsVal, weightVal, durVal, distVal, true]
    );

    if (i % 500 === 0) {
      console.log(`Processed ${i} rows...`);
    }
  }

  console.log('Import finished successfully!');
  await client.end();
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
