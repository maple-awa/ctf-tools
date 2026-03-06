import 'dart:async';
import 'dart:io';

class PortScanResult {
  const PortScanResult({
    required this.openPorts,
    required this.closedPorts,
    required this.errors,
  });

  final List<int> openPorts;
  final List<int> closedPorts;
  final List<String> errors;
}

class PortScanner {
  static Future<PortScanResult> scan({
    required String host,
    required List<int> ports,
    Duration timeout = const Duration(milliseconds: 600),
    int concurrency = 24,
  }) async {
    final openPorts = <int>[];
    final closedPorts = <int>[];
    final errors = <String>[];
    final queue = List<int>.from(ports);
    final workers = <Future<void>>[];

    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final port = queue.removeAt(0);
        try {
          final socket = await Socket.connect(host, port, timeout: timeout);
          openPorts.add(port);
          socket.destroy();
        } catch (error) {
          if (error is SocketException || error is TimeoutException) {
            closedPorts.add(port);
          } else {
            errors.add('$port: $error');
          }
        }
      }
    }

    final workerCount = ports.length < concurrency ? ports.length : concurrency;
    for (var index = 0; index < workerCount; index++) {
      workers.add(worker());
    }
    await Future.wait(workers);
    openPorts.sort();
    closedPorts.sort();
    return PortScanResult(openPorts: openPorts, closedPorts: closedPorts, errors: errors);
  }
}
