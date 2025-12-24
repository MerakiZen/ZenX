/// Base interface for data sources
/// Local and remote data sources should implement this
abstract class DataSource {
  const DataSource();
}

/// Interface for remote data sources (GraphQL, REST, etc.)
abstract class RemoteDataSource extends DataSource {
  const RemoteDataSource();
}

/// Interface for local data sources (Drift, SharedPreferences, etc.)
abstract class LocalDataSource extends DataSource {
  const LocalDataSource();
}









