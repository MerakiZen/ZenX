/// Base DTO (Data Transfer Object) class
/// All data layer models should extend this
abstract class DTO {
  const DTO();
  
  /// Convert DTO to JSON
  Map<String, dynamic> toJson();
}









