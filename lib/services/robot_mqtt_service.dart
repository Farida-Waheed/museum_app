import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../models/robot_command.dart';
import '../models/robot_command_ack.dart';
import '../models/robot_event.dart';
import 'robot_mqtt_client_factory.dart';

enum RobotMqttConnectionState {
  disabled,
  disconnected,
  connecting,
  connected,
  error,
}

class RobotMqttService extends ChangeNotifier {
  // Development placeholders only. Do not commit production broker secrets here.
  static const String devBrokerHost = String.fromEnvironment(
    'HORUS_MQTT_HOST',
    defaultValue: '',
  );
  static const int devBrokerPort = int.fromEnvironment(
    'HORUS_MQTT_PORT',
    defaultValue: 1883,
  );
  static const String devBrokerUsername = String.fromEnvironment(
    'HORUS_MQTT_USERNAME',
    defaultValue: '',
  );
  static const String devBrokerPassword = String.fromEnvironment(
    'HORUS_MQTT_PASSWORD',
    defaultValue: '',
  );
  static const bool devBrokerUseTls = bool.fromEnvironment(
    'HORUS_MQTT_TLS',
    defaultValue: false,
  );

  final String brokerHost;
  final int brokerPort;
  final String username;
  final String password;
  final bool useTls;

  MqttClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>?
      _updatesSubscription;
  String? _activeRobotId;
  String? _activeSessionId;
  RobotMqttConnectionState _connectionState;

  final StreamController<RobotCommandAck> _ackController =
      StreamController<RobotCommandAck>.broadcast();
  final StreamController<RobotEvent> _eventController =
      StreamController<RobotEvent>.broadcast();
  final StreamController<Map<String, dynamic>> _statusController =
      StreamController<Map<String, dynamic>>.broadcast();

  RobotMqttService({
    this.brokerHost = devBrokerHost,
    this.brokerPort = devBrokerPort,
    this.username = devBrokerUsername,
    this.password = devBrokerPassword,
    this.useTls = devBrokerUseTls,
  }) : _connectionState = brokerHost.trim().isEmpty
           ? RobotMqttConnectionState.disabled
           : RobotMqttConnectionState.disconnected;

  RobotMqttConnectionState get connectionState => _connectionState;
  bool get isEnabled => brokerHost.trim().isNotEmpty;
  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Stream<RobotCommandAck> get acks => _ackController.stream;
  Stream<RobotEvent> get events => _eventController.stream;
  Stream<Map<String, dynamic>> get statusUpdates => _statusController.stream;

  Future<bool> connectForSession({
    required String robotId,
    required String sessionId,
  }) async {
    if (!isEnabled) {
      _setConnectionState(RobotMqttConnectionState.disabled);
      debugPrint('MQTT disabled: broker config is missing.');
      return false;
    }

    if (robotId.trim().isEmpty || sessionId.trim().isEmpty) {
      debugPrint('MQTT connect skipped: robotId or sessionId is missing.');
      return false;
    }

    _activeRobotId = robotId;
    _activeSessionId = sessionId;

    if (isConnected) {
      _subscribeToSessionTopics(robotId: robotId, sessionId: sessionId);
      return true;
    }

    _setConnectionState(RobotMqttConnectionState.connecting);
    final clientId = 'horus_flutter_${DateTime.now().millisecondsSinceEpoch}';
    final client = createRobotMqttClient(
      brokerHost: brokerHost,
      clientId: clientId,
      brokerPort: brokerPort,
      useTls: useTls,
    );
    client.keepAlivePeriod = 30;
    client.logging(on: false);
    client.onConnected = _handleConnected;
    client.onDisconnected = _handleDisconnected;
    client.onSubscribed = (topic) => debugPrint('MQTT subscribed: $topic');
    client.onSubscribeFail = (topic) =>
        debugPrint('MQTT subscribe failed: $topic');
    client.pongCallback = () => debugPrint('MQTT ping response received.');
    var connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    if (username.trim().isNotEmpty) {
      connectionMessage = connectionMessage.authenticateAs(username, password);
    }
    client.connectionMessage = connectionMessage;

    _client = client;

    try {
      await client.connect();
    } catch (e) {
      debugPrint('MQTT connect failed: $e');
      client.disconnect();
      _setConnectionState(RobotMqttConnectionState.error);
      return false;
    }

    if (!isConnected) {
      debugPrint(
        'MQTT connect failed: ${client.connectionStatus?.returnCode}',
      );
      client.disconnect();
      _setConnectionState(RobotMqttConnectionState.error);
      return false;
    }

    _updatesSubscription?.cancel();
    _updatesSubscription = client.updates?.listen(_handleMessages);
    _subscribeToSessionTopics(robotId: robotId, sessionId: sessionId);
    return true;
  }

  Future<void> disconnect() async {
    await _updatesSubscription?.cancel();
    _updatesSubscription = null;
    _client?.disconnect();
    _client = null;
    _activeRobotId = null;
    _activeSessionId = null;
    _setConnectionState(
      isEnabled
          ? RobotMqttConnectionState.disconnected
          : RobotMqttConnectionState.disabled,
    );
  }

  Future<bool> publishCommand(RobotCommand command) async {
    if (!isEnabled) {
      debugPrint(
        'MQTT publish skipped: disabled for ${command.type.wireName}.',
      );
      return false;
    }

    if (!isConnected) {
      final connected = await connectForSession(
        robotId: command.robotId,
        sessionId: command.sessionId,
      );
      if (!connected) {
        debugPrint(
          'MQTT publish failed: not connected for ${command.type.wireName}.',
        );
        return false;
      }
    }

    final client = _client;
    if (client == null) {
      debugPrint('MQTT publish failed: client is unavailable.');
      return false;
    }

    final topic = commandTopic(command.robotId);
    final builder = MqttClientPayloadBuilder()
      ..addString(jsonEncode(command.toJson()));

    try {
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      debugPrint(
        'MQTT command published: ${command.type.wireName} '
        '(${command.commandId})',
      );
      return true;
    } catch (e) {
      debugPrint('MQTT publish failed: $e');
      return false;
    }
  }

  String commandTopic(String robotId) => 'horus/robots/$robotId/commands';
  String ackTopic(String robotId) => 'horus/robots/$robotId/acks';
  String statusTopic(String robotId) => 'horus/robots/$robotId/status';
  String eventTopic(String sessionId) => 'horus/sessions/$sessionId/events';

  void _subscribeToSessionTopics({
    required String robotId,
    required String sessionId,
  }) {
    final client = _client;
    if (client == null || !isConnected) return;
    client.subscribe(ackTopic(robotId), MqttQos.atLeastOnce);
    client.subscribe(statusTopic(robotId), MqttQos.atLeastOnce);
    client.subscribe(eventTopic(sessionId), MqttQos.atLeastOnce);
  }

  void _handleConnected() {
    debugPrint('MQTT connected.');
    _setConnectionState(RobotMqttConnectionState.connected);
    final robotId = _activeRobotId;
    final sessionId = _activeSessionId;
    if (robotId != null && sessionId != null) {
      _subscribeToSessionTopics(robotId: robotId, sessionId: sessionId);
    }
  }

  void _handleDisconnected() {
    debugPrint('MQTT disconnected.');
    _setConnectionState(
      isEnabled
          ? RobotMqttConnectionState.disconnected
          : RobotMqttConnectionState.disabled,
    );
  }

  void _handleMessages(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final received in messages) {
      final message = received.payload;
      if (message is! MqttPublishMessage) continue;

      final payload = MqttPublishPayload.bytesToStringAsString(
        message.payload.message,
      );
      final decoded = _decodePayload(payload);
      if (decoded == null) continue;

      final topic = received.topic;
      if (topic.endsWith('/acks')) {
        final ack = RobotCommandAck.fromJson(decoded);
        debugPrint('MQTT ack received: ${ack.commandId} ${ack.status}');
        _ackController.add(ack);
      } else if (topic.endsWith('/status')) {
        debugPrint('MQTT status received.');
        _statusController.add(decoded);
      } else if (topic.contains('/sessions/') && topic.endsWith('/events')) {
        final event = RobotEvent.fromJson(decoded);
        debugPrint('MQTT event received: ${event.type}');
        _eventController.add(event);
      }
    }
  }

  Map<String, dynamic>? _decodePayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      debugPrint('MQTT message ignored: payload is not an object.');
      return null;
    } catch (e) {
      debugPrint('MQTT message ignored: invalid JSON: $e');
      return null;
    }
  }

  void _setConnectionState(RobotMqttConnectionState state) {
    if (_connectionState == state) return;
    _connectionState = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _updatesSubscription?.cancel();
    _updatesSubscription = null;
    _client?.disconnect();
    _client = null;
    _ackController.close();
    _eventController.close();
    _statusController.close();
    super.dispose();
  }
}
