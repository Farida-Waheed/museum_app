import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttClient createRobotMqttClient({
  required String brokerHost,
  required String clientId,
  required int brokerPort,
  required bool useTls,
  bool useWebSocket = true,
  String wsPath = '/mqtt',
}) {
  final scheme = useTls ? 'wss' : 'ws';
  final server =
      brokerHost.startsWith('ws://') || brokerHost.startsWith('wss://')
      ? brokerHost
      : '$scheme://$brokerHost$wsPath';
  return MqttBrowserClient.withPort(server, clientId, brokerPort);
}
