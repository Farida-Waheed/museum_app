import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient createRobotMqttClient({
  required String brokerHost,
  required String clientId,
  required int brokerPort,
  required bool useTls,
  bool useWebSocket = false,
  String wsPath = '/mqtt',
}) {
  if (useWebSocket) {
    // MQTT over WebSocket (TLS). Used to traverse networks that block the
    // native MQTT port 8883 but allow web traffic. HiveMQ Cloud exposes this
    // on port 8884 at path /mqtt. The wss:// scheme provides the TLS layer.
    final scheme = useTls ? 'wss' : 'ws';
    final server =
        brokerHost.startsWith('ws://') || brokerHost.startsWith('wss://')
        ? brokerHost
        : '$scheme://$brokerHost$wsPath';
    final client = MqttServerClient.withPort(server, clientId, brokerPort);
    client.useWebSocket = true;
    client.secure = useTls;
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    return client;
  }

  final client = MqttServerClient.withPort(brokerHost, clientId, brokerPort);
  client.secure = useTls;
  return client;
}
