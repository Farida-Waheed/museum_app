import 'package:mqtt_client/mqtt_client.dart';

MqttClient createRobotMqttClient({
  required String brokerHost,
  required String clientId,
  required int brokerPort,
  required bool useTls,
}) {
  throw UnsupportedError('MQTT is not supported on this platform.');
}
