/// GraphQL queries and mutations for ZenX
/// These will be used by the GraphQL client to communicate with the API Gateway

class GraphQLQueries {
  GraphQLQueries._();

  // Authentication
  static const String login = '''
    mutation Login(\$email: String!, \$password: String!) {
      login(email: \$email, password: \$password) {
        accessToken
        refreshToken
        expiresAt
      }
    }
  ''';

  static const String register = '''
    mutation Register(\$email: String!, \$password: String!, \$displayName: String!) {
      register(email: \$email, password: \$password, displayName: \$displayName) {
        accessToken
        refreshToken
        expiresAt
      }
    }
  ''';

  static const String refreshToken = '''
    mutation RefreshToken(\$refreshToken: String!) {
      refreshToken(refreshToken: \$refreshToken) {
        accessToken
        refreshToken
        expiresAt
      }
    }
  ''';

  static const String profileOverview = '''
    query ProfileOverview(\$range: MeasurementRangeInput) {
      profile {
        id
        displayName
        bio
        avatarUrl
        dateOfBirth
        gender
      }
      measurements(range: \$range) {
        id
        userId
        measurementDate
        weightKg
        bodyFatPercentage
        muscleMassKg
        measurementsJson
      }
      progressSnapshot {
        totalVolumeKg
        workoutCount
      }
    }
  ''';

  static const String updateProfile = '''
    mutation UpdateProfile(\$input: ProfileInput!) {
      updateProfile(input: \$input) {
        id
        displayName
        bio
        avatarUrl
        dateOfBirth
        gender
      }
    }
  ''';

  static const String recordMeasurement = '''
    mutation RecordMeasurement(\$input: MeasurementInput!) {
      recordMeasurement(input: \$input) {
        id
        measurementDate
        weightKg
        bodyFatPercentage
        muscleMassKg
      }
    }
  ''';

  // Workouts
  static const String getWorkouts = '''
    query GetWorkouts(\$limit: Int, \$after: String) {
      workouts(limit: \$limit, after: \$after) {
        id
        userId
        name
        notes
        startedAt
        completedAt
        exercises {
          exerciseId
          order
          sets {
            setNumber
            reps
            weightKg
            rpe
            completed
          }
        }
      }
    }
  ''';

  static const String getWorkout = '''
    query GetWorkout(\$id: ID!) {
      workout(id: \$id) {
        id
        userId
        name
        notes
        startedAt
        completedAt
        durationSeconds
        totalVolumeKg
        exercises {
          id
          exerciseId
          orderIndex
          exercise {
            id
            name
            primaryMuscleGroup
          }
          sets {
            id
            setNumber
            reps
            weightKg
            rpe
            notes
            completed
          }
        }
        createdAt
        updatedAt
      }
    }
  ''';

  static const String createWorkout = '''
    mutation CreateWorkout(\$input: WorkoutInput!) {
      createWorkout(input: \$input) {
        id
        userId
        name
        notes
        startedAt
        completedAt
        exercises {
          exerciseId
          order
          sets {
            setNumber
            reps
            weightKg
            rpe
            completed
          }
        }
        createdAt
      }
    }
  ''';

  // Analytics
  static const String getWorkoutCalendar = '''
    query GetWorkoutCalendar(\$startDate: String!, \$endDate: String!) {
      workoutCalendar(startDate: \$startDate, endDate: \$endDate) {
        workoutDays
        totalWorkouts
      }
    }
  ''';

  static const String getMuscleGroupStats = '''
    query GetMuscleGroupStats(\$dateRange: DateRangeInput) {
      muscleGroupStats(dateRange: \$dateRange) {
        muscleGroup
        setCount
        volume
        percentage
      }
    }
  ''';

  static const String getTopExercises = '''
    query GetTopExercises(\$limit: Int, \$dateRange: DateRangeInput) {
      topExercises(limit: \$limit, dateRange: \$dateRange) {
        exerciseId
        exerciseName
        workoutCount
        lastPerformed
        averageWeight
      }
    }
  ''';

  static const String getExercisePerformance = '''
    query GetExercisePerformance(\$exerciseId: ID!) {
      exercisePerformance(exerciseId: \$exerciseId) {
        exerciseId
        exerciseName
        heaviestWeight
        projectedOneRM
        bestSetVolume
        bestSessionVolume
        mostReps
        personalRecords {
          recordType
          value
          achievedAt
        }
        history {
          workoutId
          date
          weight
          reps
          oneRM
          volume
        }
      }
    }
  ''';

  // Exercises
  static const String getExercises = '''
<<<<<<< Updated upstream
    query GetExercises(\$category: String) {
      exercises(category: \$category) {
=======
    query GetExercises(\$query: String, \$category: String) {
      exercises(query: \$query, category: \$category) {
>>>>>>> Stashed changes
        id
        name
        description
        category
        primaryMuscleGroup
        secondaryMuscleGroups
        equipmentRequired
        difficultyLevel
        isCustom
        createdAt
      }
    }
  ''';
<<<<<<< Updated upstream

  static const String getExercise = '''
    query GetExercise(\$id: ID!) {
      exercise(id: \$id) {
        id
        name
        description
        category
        primaryMuscleGroup
        secondaryMuscleGroups
        equipmentRequired
        difficultyLevel
        isCustom
        createdAt
      }
    }
  ''';

  // Analytics
  static const String progressSnapshot = '''
    query ProgressSnapshot {
      progressSnapshot {
        capturedAt
        totalVolumeKg
        averageRpe
        workoutCount
        prs {
          exerciseId
          recordType
          value
          achievedAt
          exercise {
            id
            name
            category
          }
        }
      }
    }
  ''';

  static const String personalRecords = '''
    query PersonalRecords {
      personalRecords {
        exerciseId
        recordType
        value
        achievedAt
        exercise {
          id
          name
          category
        }
      }
    }
  ''';

  // Profile
  static const String getBodyMeasurements = '''
    query GetBodyMeasurements(\$userId: ID!, \$limit: Int, \$offset: Int) {
      bodyMeasurements(userId: \$userId, limit: \$limit, offset: \$offset) {
        id
        userId
        measurementDate
        weightKg
        bodyFatPercentage
        muscleMassKg
        measurements
        createdAt
      }
    }
  ''';

  static const String feed = '''
    query Feed(\$limit: Int, \$cursor: String) {
      feed(limit: \$limit, cursor: \$cursor) {
        edges {
          id
          workoutId
          userId
          caption
          imageUrl
          createdAt
          updatedAt
          likesCount
          commentsCount
          isLiked
          likedByUserIds
          workout {
            id
            userId
            name
            notes
            startedAt
            completedAt
          }
          authorProfile {
            id
            displayName
            avatarUrl
          }
        }
        nextCursor
      }
    }
  ''';

  static const String discoverFeed = '''
    query DiscoverFeed(\$limit: Int, \$cursor: String) {
      discoverFeed(limit: \$limit, cursor: \$cursor) {
        edges {
          id
          workoutId
          userId
          caption
          imageUrl
          createdAt
          updatedAt
          likesCount
          commentsCount
          isLiked
          likedByUserIds
          workout {
            id
            userId
            name
            notes
            startedAt
            completedAt
          }
          authorProfile {
            id
            displayName
            avatarUrl
          }
        }
        nextCursor
      }
    }
  ''';

  static const String feedComments = '''
    query FeedComments(\$postId: ID!, \$limit: Int, \$cursor: String) {
      feedComments(postId: \$postId, limit: \$limit, cursor: \$cursor) {
        comments {
          id
          postId
          userId
          body
          createdAt
          authorProfile {
            id
            displayName
            avatarUrl
          }
        }
        nextCursor
      }
    }
  ''';

  static const String toggleFeedLike = '''
    mutation ToggleFeedLike(\$postId: ID!) {
      toggleFeedLike(postId: \$postId) {
        id
        likesCount
        commentsCount
        isLiked
        likedByUserIds
      }
    }
  ''';

  static const String addFeedComment = '''
    mutation AddFeedComment(\$postId: ID!, \$body: String!) {
      addFeedComment(postId: \$postId, body: \$body) {
        id
        postId
        userId
        body
        createdAt
        authorProfile {
          id
          displayName
          avatarUrl
        }
      }
    }
  ''';

  static const String notifications = '''
    query Notifications(\$limit: Int, \$cursor: String, \$status: String) {
      notifications(limit: \$limit, cursor: \$cursor, status: \$status) {
        nodes {
          id
          template
          status
          createdAt
          scheduledFor
          sentAt
          data {
            key
            value
          }
        }
        nextCursor
      }
    }
  ''';

  static const String markNotificationRead = '''
    mutation MarkNotificationRead(\$notificationId: ID!) {
      markNotificationRead(notificationId: \$notificationId) {
        id
        status
      }
    }
  ''';
=======
>>>>>>> Stashed changes
}

/// GraphQL subscriptions for real-time updates
class GraphQLSubscriptions {
  GraphQLSubscriptions._();

  static const String workoutUpdates = '''
    subscription WorkoutUpdates(\$workoutId: ID!) {
      workoutUpdates(workoutId: \$workoutId) {
        id
        type
        data
        timestamp
      }
    }
  ''';

  static const String notifications = '''
    subscription Notifications(\$userId: ID!) {
      notifications(userId: \$userId) {
        id
        type
        title
        body
        data
        read
        createdAt
      }
    }
  ''';
}
