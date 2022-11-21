import 'package:olaclick/src/model/pushNotification.dart';
import 'package:olaclick/src/provider/notification_provider.dart';

abstract class Notification {
  Future<PushResponseModel> registerTokenPush(
      String url, String companyId, String pushToken);
  Future<PushResponseModel> unRegisterTokenPush(
      String url, String companyId, String pushToken);
}

class NotificationController extends Notification {
  NotificationProvider authProvider = NotificationProvider();
  @override
  Future<PushResponseModel> registerTokenPush(
      String url, String companyId, String pushToken) {
    return authProvider.registerTokenPush(url, companyId, pushToken);
  }

  @override
  Future<PushResponseModel> unRegisterTokenPush(
      String url, String companyId, String pushToken) {
    return authProvider.unRegisterTokenPush(url, companyId, pushToken);
  }
}
