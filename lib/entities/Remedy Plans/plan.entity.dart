import 'package:objectbox/objectbox.dart';
import 'package:administration_application/entities/Remedies/item.entity.dart';
import 'package:administration_application/entities/Health Issues/condition.entity.dart';

@Entity()
class Plans {
  @Id()
  int id = 0;

  @Property()
  String name;


  @Property()
  String instructions;

  @Property()
  String dosage;

  @Property()
  String precautions;

  @Property()
  String references;

  @Transient()
  bool isSelected = false; // Add this line

  final Item = ToOne<Items>();
  final Condition = ToOne<Conditions>();



  Plans({
    required this.id,
    required this.name,
    required this.instructions,
    required this.dosage,
    required this.precautions,
    required this.references,
  });
}
