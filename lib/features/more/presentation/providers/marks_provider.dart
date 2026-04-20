import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vsync/core/exceptions.dart';
import 'package:vsync/core/services/service_layer.dart';
import 'package:vsync/core/utils/featureflags/feature_flags.dart';
import 'package:vsync/src/api/vtop/types.dart';
part 'marks_provider.g.dart';

@riverpod
class Marks extends _$Marks {
  @override
  Future<MarksData> build() async {
    final services = await ref.watch(appServicesProvider.future);
    MarksData data = await services.vtopDataRepository.loadMarks();
    if (data.records.isEmpty) {
      data = await _update();
    }
    return data;
  }

  Future<void> updatemarks() async {
    MarksData data = await _update();
    state = AsyncData(data);
  }

  Future<MarksData> _update() async {
    final services = await ref.read(appServicesProvider.future);
    var gb = await ref.read(gbProvider.future);
    var feature = gb.feature("fetch-marks");
    if (feature.on && feature.value) {
      return services.vtopDataRepository.loadMarks(refresh: true);
    } else {
      throw FeatureDisabledException("Marks Feature Disabled");
    }
  }
}
