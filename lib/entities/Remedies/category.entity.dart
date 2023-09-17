import 'package:objectbox/objectbox.dart';
import 'package:administration_application/entities/Remedies/item.entity.dart';

@Entity()
class Categories {
  @Id()
  int id = 0;

  @Property()
  String name;

  @Transient()
  bool isSelected = false; // Add this line

  @Backlink('category')
  final items = ToMany<Items>();

  Categories({
    required this.id,
    required this.name,
  });
}
