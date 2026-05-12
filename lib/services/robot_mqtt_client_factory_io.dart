import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient createRobotMqttClient({
  required String brokerHost,
  required String clientId,
  required int brokerPort,
  required bool useTls,
}) {
  final client = MqttServerClient.withPort(brokerHost, clientId, brokerPort);
  client.secure = useTls;
  return client;
}
