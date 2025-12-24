import '../../domain/entity.dart';
import '../dto.dart';

/// Base mapper interface for converting between DTOs and Entities
abstract class Mapper<D extends DTO, E extends Entity> {
  /// Convert DTO to Entity
  E toEntity(D dto);

  /// Convert Entity to DTO
  D toDto(E entity);

  /// Convert list of DTOs to list of Entities
  List<E> toEntityList(List<D> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }

  /// Convert list of Entities to list of DTOs
  List<D> toDtoList(List<E> entities) {
    return entities.map((entity) => toDto(entity)).toList();
  }
}









