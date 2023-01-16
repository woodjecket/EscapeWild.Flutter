import 'package:json_annotation/json_annotation.dart';

part 'recipe.g.dart';

@JsonSerializable(createToJson: false)
class TagMassEntry {
  @JsonKey()
  final Iterable<String> tags;
  @JsonKey()
  final int? mass;

  const TagMassEntry(this.tags, this.mass);

  factory TagMassEntry.fromJson(Map<String, dynamic> json) => _$TagMassEntryFromJson(json);

  @override
  String toString() {
    final mass = this.mass;
    final tagsStr = tags.join(", ");
    return mass == null ? tagsStr : "$tagsStr ${mass}g";
  }
}