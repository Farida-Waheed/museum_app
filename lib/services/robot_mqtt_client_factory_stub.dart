import 'package:mqtt_client/mqtt_client.dart';

MqttClient createRobotMqttClient({
  required String brokerHost,
  required String clientId,
  required int brokerPort,
  required bool useTls,
  bool useWebSocket = false,
  String wsPath = '/mqtt',
}) {
  throw UnsupportedError('MQTT is not supported on this platform.');
}
