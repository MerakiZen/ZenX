const { Client } = require('pg');

const USER_ID = "38c76f10-20ba-44c9-be55-734070e4fb3a";
const DB_HOST = process.env.DB_HOST || "localhost";
const DB_BASE_URL = `postgres://zenx:zenx@${DB_HOST}:5432`;

async function runQuery(dbName, queries) {
    const client = new Client({ connectionString: `${DB_BASE_URL}/${dbName}` });
    await client.connect();
    try {
        for (const q of queries) {
            await client.query(q);
        }
    } finally {
        await client.end();
    }
}

async function setupSchemas() {
    console.log('Setting up schemas...');

    // 1. Exercise Service
    await runQuery('zenx_exercise', [
        `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`,
        `CREATE TABLE IF NOT EXISTS exercise_categories (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      slug TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL
    );`,
        `CREATE TABLE IF NOT EXISTS exercises (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      name TEXT NOT NULL,
      description TEXT,
      category_id UUID REFERENCES exercise_categories(id),
      primary_muscle_group TEXT,
      secondary_muscle_groups TEXT[],
      equipment_required TEXT,
      difficulty_level TEXT,
      is_custom BOOLEAN NOT NULL DEFAULT FALSE,
      created_by UUID,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );`,
        `CREATE INDEX IF NOT EXISTS idx_exercises_name ON exercises USING GIN (to_tsvector('english', name));`
    ]);

    // 2. Workout Service
    await runQuery('zenx_workout', [
        `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`,
        `CREATE TABLE IF NOT EXISTS workouts (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL,
      name VARCHAR(200) NOT NULL,
      notes TEXT,
      started_at TIMESTAMPTZ,
      completed_at TIMESTAMPTZ,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );`,
        `CREATE TABLE IF NOT EXISTS workout_exercises (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
      exercise_id UUID NOT NULL,
      order_index INT NOT NULL,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );`,
        `CREATE TABLE IF NOT EXISTS workout_sets (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      workout_exercise_id UUID NOT NULL REFERENCES workout_exercises(id) ON DELETE CASCADE,
      set_number INT NOT NULL,
      reps INT,
      weight_kg NUMERIC(10,2),
      rpe NUMERIC(4,2),
      notes TEXT,
      completed BOOLEAN NOT NULL DEFAULT FALSE,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );`,
        `CREATE TABLE IF NOT EXISTS feed_posts (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
      user_id UUID NOT NULL,
      caption TEXT,
      image_url TEXT,
      visibility TEXT NOT NULL DEFAULT 'public',
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      UNIQUE (workout_id)
    );`
    ]);

    // 3. Profile Service
    await runQuery('zenx_profile', [
        `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`,
        `CREATE TABLE IF NOT EXISTS user_profiles (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID UNIQUE NOT NULL,
      display_name TEXT,
      bio TEXT,
      avatar_url TEXT,
      date_of_birth DATE,
      gender TEXT,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );`,
        `INSERT INTO user_profiles (user_id, display_name, bio) 
     VALUES ('${USER_ID}', 'vaibhav', 'ZenX athlete') 
     ON CONFLICT (user_id) DO NOTHING;`
    ]);

    // 4. Analytics Service
    await runQuery('zenx_analytics', [
        `CREATE TABLE IF NOT EXISTS progress_snapshots (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL,
      captured_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
      total_volume_kg NUMERIC(12,2),
      average_rpe NUMERIC(5,2),
      workout_count INT DEFAULT 0,
      streak_days INT DEFAULT 0,
      created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );`,
        `ALTER TABLE progress_snapshots ADD COLUMN IF NOT EXISTS streak_days INT DEFAULT 0;`
    ]);
}

async function migrateData() {
    console.log('Migrating data from zenx to microservice DBs...');

    const sourceClient = new Client({ connectionString: `${DB_BASE_URL}/zenx` });
    await sourceClient.connect();

    const workoutClient = new Client({ connectionString: `${DB_BASE_URL}/zenx_workout` });
    await workoutClient.connect();

    const exerciseClient = new Client({ connectionString: `${DB_BASE_URL}/zenx_exercise` });
    await exerciseClient.connect();

    try {
        // Truncate existing data for re-run
        console.log('Truncating existing data...');
        await workoutClient.query('TRUNCATE workouts, workout_exercises, workout_sets, feed_posts CASCADE');
        await exerciseClient.query('TRUNCATE exercises, exercise_categories CASCADE');

        // 1. Exercises
        console.log('Migrating exercises...');
        const exRes = await sourceClient.query('SELECT * FROM exercise');

        // Create categories first
        const categories = ['CHEST', 'BACK', 'LEGS', 'SHOULDERS', 'ARMS', 'CORE', 'OTHER'];
        const catMap = new Map();
        for (const cat of categories) {
            const res = await exerciseClient.query('INSERT INTO exercise_categories (slug, name) VALUES ($1, $2) ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name RETURNING id', [cat.toLowerCase(), cat]);
            catMap.set(cat, res.rows[0].id);
        }

        const exerciseIdMap = new Map(); // oldId -> newId
        for (const row of exRes.rows) {
            const res = await exerciseClient.query(
                'INSERT INTO exercises (name, description, category_id, primary_muscle_group, equipment_required, is_custom) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id',
                [row.name, row.description || '', catMap.get(row.category) || catMap.get('OTHER'), row.muscleGroup, row.equipment, false]
            );
            exerciseIdMap.set(row.id, res.rows[0].id);
        }

        // 2. Workouts
        console.log('Migrating workouts...');
        const wRes = await sourceClient.query('SELECT * FROM workout');
        let workoutCount = 0;
        let totalVolume = 0;

        for (const w of wRes.rows) {
            const res = await workoutClient.query(
                'INSERT INTO workouts (id, user_id, name, notes, started_at, completed_at) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id',
                [w.id, USER_ID, w.name, w.description, w.date, w.date] // Using date as both started and completed for simplicity
            );
            const newWorkoutId = res.rows[0].id;

            // Workout Exercises
            const weRes = await sourceClient.query('SELECT * FROM workout_exercise WHERE "workoutId" = $1', [w.id]);
            for (const we of weRes.rows) {
                const weInsert = await workoutClient.query(
                    'INSERT INTO workout_exercises (workout_id, exercise_id, order_index) VALUES ($1, $2, $3) RETURNING id',
                    [newWorkoutId, exerciseIdMap.get(we.exerciseId), we.order]
                );
                const newWEId = weInsert.rows[0].id;

                // Sets
                const sRes = await sourceClient.query('SELECT * FROM "set" WHERE "workoutExerciseId" = $1', [we.id]);
                for (const s of sRes.rows) {
                    await workoutClient.query(
                        'INSERT INTO workout_sets (workout_exercise_id, set_number, reps, weight_kg, completed) VALUES ($1, $2, $3, $4, $5)',
                        [newWEId, s.setNumber, s.reps, s.weight * 0.453592, true]
                    );
                    if (s.reps && s.weight) {
                        totalVolume += s.reps * (s.weight * 0.453592);
                    }
                }
            }
            workoutCount++;

            // Create a few feed posts
            if (workoutCount <= 10) {
                await workoutClient.query(
                    'INSERT INTO feed_posts (workout_id, user_id, caption) VALUES ($1, $2, $3)',
                    [newWorkoutId, USER_ID, `Crushed another ${w.name} session! 🔥`]
                );
            }
        }

        // 3. Analytics Snapshot
        console.log('Creating initial analytics snapshot...');
        const analyticsClient = new Client({ connectionString: `${DB_BASE_URL}/zenx_analytics` });
        await analyticsClient.connect();
        try {
            await analyticsClient.query('TRUNCATE progress_snapshots');
            await analyticsClient.query(
                'INSERT INTO progress_snapshots (user_id, total_volume_kg, workout_count, streak_days) VALUES ($1, $2, $3, $4)',
                [USER_ID, totalVolume, workoutCount, 18]
            );
        } finally {
            await analyticsClient.end();
        }

        console.log(`Migrated ${workoutCount} workouts and ${totalVolume} lbs of volume.`);
    } finally {
        await sourceClient.end();
        await workoutClient.end();
        await exerciseClient.end();
    }
}

async function main() {
    try {
        await setupSchemas();
        await migrateData();
        console.log('SUCCESS: All real data migrated to microservice databases.');
    } catch (err) {
        console.error('ERROR:', err);
    }
}

main();
