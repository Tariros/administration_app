import 'package:objectbox/objectbox.dart';
import 'package:administration_application/entities/Remedies/item.entity.dart';

@Entity()
class Interactions {
  @Id()
  int id = 0;

  @Property()
  String description;

  @Backlink('interaction')
  final items = ToMany<Items>();

  Interactions({
    required this.id,
    required this.description,
  });
}