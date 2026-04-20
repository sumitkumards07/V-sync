import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vsync/core/utils/users/vtop_users_utils.dart';
import 'package:vsync/core/utils/entity/vtop_user_entity.dart';

part 'vtop_user_provider.g.dart';

@Riverpod(keepAlive: true)
class VtopUser extends _$VtopUser {
  @override
  Future<VtopUserEntity> build() async {
    var user =
        await ref.read(vtopusersutilsProvider.notifier).vtopUserDefault();
    if (user == null) {
      throw StateError('No active VTOP account is available.');
    }

    return user;
  }
}
