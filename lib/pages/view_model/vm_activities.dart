import 'package:ac_smart/models/activity.dart';
import 'package:ac_smart/pages/ui/activity_container.dart';

consultarAtividadeContainer(id) {
  // filtro de reprovado ou não
  if (atividades[id]) return ActivityContainer(id);
}
