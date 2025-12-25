// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$exercisesHash() => r'2e185117c198e738d8d9c9654732c0dd72470978';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider to fetch all exercises with optional filters
///
/// Copied from [exercises].
@ProviderFor(exercises)
const exercisesProvider = ExercisesFamily();

/// Provider to fetch all exercises with optional filters
///
/// Copied from [exercises].
class ExercisesFamily extends Family<AsyncValue<List<Exercise>>> {
  /// Provider to fetch all exercises with optional filters
  ///
  /// Copied from [exercises].
  const ExercisesFamily();

  /// Provider to fetch all exercises with optional filters
  ///
  /// Copied from [exercises].
  ExercisesProvider call({
    String? query,
    String? category,
  }) {
    return ExercisesProvider(
      query: query,
      category: category,
    );
  }

  @override
  ExercisesProvider getProviderOverride(
    covariant ExercisesProvider provider,
  ) {
    return call(
      query: provider.query,
      category: provider.category,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'exercisesProvider';
}

/// Provider to fetch all exercises with optional filters
///
/// Copied from [exercises].
class ExercisesProvider extends AutoDisposeFutureProvider<List<Exercise>> {
  /// Provider to fetch all exercises with optional filters
  ///
  /// Copied from [exercises].
  ExercisesProvider({
    String? query,
    String? category,
  }) : this._internal(
          (ref) => exercises(
            ref as ExercisesRef,
            query: query,
            category: category,
          ),
          from: exercisesProvider,
          name: r'exercisesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$exercisesHash,
          dependencies: ExercisesFamily._dependencies,
          allTransitiveDependencies: ExercisesFamily._allTransitiveDependencies,
          query: query,
          category: category,
        );

  ExercisesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.category,
  }) : super.internal();

  final String? query;
  final String? category;

  @override
  Override overrideWith(
    FutureOr<List<Exercise>> Function(ExercisesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExercisesProvider._internal(
        (ref) => create(ref as ExercisesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Exercise>> createElement() {
    return _ExercisesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExercisesProvider &&
        other.query == query &&
        other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExercisesRef on AutoDisposeFutureProviderRef<List<Exercise>> {
  /// The parameter `query` of this provider.
  String? get query;

  /// The parameter `category` of this provider.
  String? get category;
}

class _ExercisesProviderElement
    extends AutoDisposeFutureProviderElement<List<Exercise>> with ExercisesRef {
  _ExercisesProviderElement(super.provider);

  @override
  String? get query => (origin as ExercisesProvider).query;
  @override
  String? get category => (origin as ExercisesProvider).category;
}

String _$searchExercisesHash() => r'2ddcbdc6759cb7ebb7183cd50af0df9b17c0042b';

/// Provider to search exercises by name
///
/// Copied from [searchExercises].
@ProviderFor(searchExercises)
const searchExercisesProvider = SearchExercisesFamily();

/// Provider to search exercises by name
///
/// Copied from [searchExercises].
class SearchExercisesFamily extends Family<AsyncValue<List<Exercise>>> {
  /// Provider to search exercises by name
  ///
  /// Copied from [searchExercises].
  const SearchExercisesFamily();

  /// Provider to search exercises by name
  ///
  /// Copied from [searchExercises].
  SearchExercisesProvider call(
    String searchQuery,
  ) {
    return SearchExercisesProvider(
      searchQuery,
    );
  }

  @override
  SearchExercisesProvider getProviderOverride(
    covariant SearchExercisesProvider provider,
  ) {
    return call(
      provider.searchQuery,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchExercisesProvider';
}

/// Provider to search exercises by name
///
/// Copied from [searchExercises].
class SearchExercisesProvider
    extends AutoDisposeFutureProvider<List<Exercise>> {
  /// Provider to search exercises by name
  ///
  /// Copied from [searchExercises].
  SearchExercisesProvider(
    String searchQuery,
  ) : this._internal(
          (ref) => searchExercises(
            ref as SearchExercisesRef,
            searchQuery,
          ),
          from: searchExercisesProvider,
          name: r'searchExercisesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchExercisesHash,
          dependencies: SearchExercisesFamily._dependencies,
          allTransitiveDependencies:
              SearchExercisesFamily._allTransitiveDependencies,
          searchQuery: searchQuery,
        );

  SearchExercisesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
  }) : super.internal();

  final String searchQuery;

  @override
  Override overrideWith(
    FutureOr<List<Exercise>> Function(SearchExercisesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchExercisesProvider._internal(
        (ref) => create(ref as SearchExercisesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Exercise>> createElement() {
    return _SearchExercisesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchExercisesProvider && other.searchQuery == searchQuery;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchExercisesRef on AutoDisposeFutureProviderRef<List<Exercise>> {
  /// The parameter `searchQuery` of this provider.
  String get searchQuery;
}

class _SearchExercisesProviderElement
    extends AutoDisposeFutureProviderElement<List<Exercise>>
    with SearchExercisesRef {
  _SearchExercisesProviderElement(super.provider);

  @override
  String get searchQuery => (origin as SearchExercisesProvider).searchQuery;
}

String _$exercisesByCategoryHash() =>
    r'a9dc5cd1361766e89ff7b36a6b9a951f84a440c9';

/// Provider to filter exercises by category
///
/// Copied from [exercisesByCategory].
@ProviderFor(exercisesByCategory)
const exercisesByCategoryProvider = ExercisesByCategoryFamily();

/// Provider to filter exercises by category
///
/// Copied from [exercisesByCategory].
class ExercisesByCategoryFamily extends Family<AsyncValue<List<Exercise>>> {
  /// Provider to filter exercises by category
  ///
  /// Copied from [exercisesByCategory].
  const ExercisesByCategoryFamily();

  /// Provider to filter exercises by category
  ///
  /// Copied from [exercisesByCategory].
  ExercisesByCategoryProvider call(
    String category,
  ) {
    return ExercisesByCategoryProvider(
      category,
    );
  }

  @override
  ExercisesByCategoryProvider getProviderOverride(
    covariant ExercisesByCategoryProvider provider,
  ) {
    return call(
      provider.category,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'exercisesByCategoryProvider';
}

/// Provider to filter exercises by category
///
/// Copied from [exercisesByCategory].
class ExercisesByCategoryProvider
    extends AutoDisposeFutureProvider<List<Exercise>> {
  /// Provider to filter exercises by category
  ///
  /// Copied from [exercisesByCategory].
  ExercisesByCategoryProvider(
    String category,
  ) : this._internal(
          (ref) => exercisesByCategory(
            ref as ExercisesByCategoryRef,
            category,
          ),
          from: exercisesByCategoryProvider,
          name: r'exercisesByCategoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$exercisesByCategoryHash,
          dependencies: ExercisesByCategoryFamily._dependencies,
          allTransitiveDependencies:
              ExercisesByCategoryFamily._allTransitiveDependencies,
          category: category,
        );

  ExercisesByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String category;

  @override
  Override overrideWith(
    FutureOr<List<Exercise>> Function(ExercisesByCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ExercisesByCategoryProvider._internal(
        (ref) => create(ref as ExercisesByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Exercise>> createElement() {
    return _ExercisesByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExercisesByCategoryProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExercisesByCategoryRef on AutoDisposeFutureProviderRef<List<Exercise>> {
  /// The parameter `category` of this provider.
  String get category;
}

class _ExercisesByCategoryProviderElement
    extends AutoDisposeFutureProviderElement<List<Exercise>>
    with ExercisesByCategoryRef {
  _ExercisesByCategoryProviderElement(super.provider);

  @override
  String get category => (origin as ExercisesByCategoryProvider).category;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
