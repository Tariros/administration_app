import 'package:objectbox/objectbox.dart';
import 'package:administration_application/entities/Remedies/category.entity.dart';
import 'package:administration_application/entities/Remedy Plans/plan.entity.dart';
import 'package:administration_application/entities/Remedies/interaction.entity.dart';

@Entity()
class Items {
  @Id()
  int id = 0;

  @Property()
  String name;

  @Property()
  String alsoCalled;

  @Property()
  String uses;

  @Property()
  String caution;

  @Property()
  String conscientiousConsumerInformation;

  @Property()
  String references;

  @Transient()
  bool isSelected = false; // Add this line

  @Backlink('item')
  final plan = ToMany<Plans>();

  final category = ToOne<Categories>();
  final interaction = ToMany<Interactions>();

  Items({
    required this.id,
    required this.name,
    required this.alsoCalled,
    required this.uses,
    required this.caution,
    required this.conscientiousConsumerInformation,
    required this.references,
  });
}
