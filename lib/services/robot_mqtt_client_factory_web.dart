import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttClient createRobotMqttClient({
  required String brokerHost,
  required String clientId,
  required int brokerPort,
  required bool useTls,
}) {
  final scheme = useTls ? 'wss' : 'ws';
  final server =
      brokerHost.startsWith('ws://') || brokerHost.startsWith('wss://')
      ? brokerHost
      : '$scheme://$brokerHost/mqtt';
  return MqttBrowserClient.withPort(server, clientId, brokerPort);
}
