import 'package:objectbox/objectbox.dart';
import 'package:administration_application/entities/Remedy Plans/plan.entity.dart';

@Entity()
class Conditions {
  @Id()
  int id = 0;

  @Property()
  String name;

  @Property()
  String description;

  @Property()
  List<String> causes;

  @Property()
  List<String> complications;

  @Transient()
  bool isSelected = false; // Add this line

  @Backlink('condition')
  final plan = ToMany<Plans>();


  Conditions({
    required this.id,
    required this.name,
    required this.description,
    required this.complications,
    required this.causes,
  });
}
