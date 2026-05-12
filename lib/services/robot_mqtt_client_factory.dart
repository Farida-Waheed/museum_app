import 'package:mqtt_client/mqtt_client.dart';

import 'robot_mqtt_client_factory_stub.dart'
    if (dart.library.io) 'robot_mqtt_client_factory_io.dart'
    if (dart.library.html) 'robot_mqtt_client_factory_web.dart'
    as platform_factory;

MqttClient createRobotMqttClient({
  required String brokerHost,
  required String clientId,
  required int brokerPort,
  required bool useTls,
}) {
  return platform_factory.createRobotMqttClient(
    brokerHost: brokerHost,
    clientId: clientId,
    brokerPort: brokerPort,
    useTls: useTls,
  );
}
