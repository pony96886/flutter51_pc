import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:chaguaner2023/utils/cache/image_decrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:hive/hive.dart';
import 'dart:ui' as ui show Codec;

_Worker? _worker;
Completer? _completer;

class _ImageLoadMessage {
  final int id;
  final String cacheKey;
  final String hivePath;
  final String boxKey;
  final String url;

  _ImageLoadMessage({
    required this.id,
    required this.cacheKey,
    required this.hivePath,
    required this.boxKey,
    required this.url,
  });
}

class _ImageLoadResponse {
  final int id;
  final Object? data;

  _ImageLoadResponse({required this.id, this.data});
}

class _ChunkEventMessage {
  final int id;
  final int cumulative;
  final int? total;

  _ChunkEventMessage({
    required this.id,
    required this.cumulative,
    this.total,
  });
}

class _ConnectionData {
  final ReceivePort receivePort;
  final SendPort sendPort;

  _ConnectionData({required this.receivePort, required this.sendPort});
}

Future<ui.Codec> imageLoadAsync(
  NetworkImage key,
  String cacheKey,
  StreamController<ImageChunkEvent> chunkEvents,
  Future<ui.Codec> Function(Uint8List buffer) decode,
  String hivePath,
  String boxKey,
) async {
  if (_worker == null) {
    if (_completer == null) {
      _completer = Completer();
      _worker = await _Worker.spawn();
      _completer?.complete();
    } else {
      await _completer?.future;
    }
  }

  try {
    final data = await _worker!.fetchImage(key.url, cacheKey, hivePath, boxKey, chunkEvents);
    return decode(data);
  } catch (e) {
    scheduleMicrotask(() {
      PaintingBinding.instance.imageCache.evict(key);
    });
    rethrow;
  } finally {
    chunkEvents.close();
  }
}

Future<Uint8List> downImageLoadAsync(String url, String cacheKey) async {
  try {
    final Uri resolved = Uri.base.resolve(url);

    final httpClient = HttpClient()..autoUncompress = false;

    final HttpClientRequest request = await httpClient.getUrl(resolved);

    final HttpClientResponse response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<List<int>>(<int>[]);
      throw NetworkImageLoadException(statusCode: response.statusCode, uri: resolved);
    }
    final Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    if (bytes.lengthInBytes == 0) {
      throw Exception('NetworkImage is an empty file: $resolved');
    }
    final decrypted = await imageDecrypt(bytes);
    return decrypted;
  } catch (_) {
    rethrow;
  }
}

class _Worker {
  final SendPort _commands;
  final ReceivePort _responses;
  final Map<int, Completer<Uint8List>> _activeRequests = {};
  final Map<int, StreamController<ImageChunkEvent>> _chunkEvents = {};

  int _idCounter = 0;
  bool _closed = false;

  Future<Uint8List> fetchImage(String url, String cacheKey, String hivePath, String boxKey,
      StreamController<ImageChunkEvent> chunkEventsStream) {
    if (_closed) throw StateError('Closed');
    final completer = Completer<Uint8List>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _chunkEvents[id] = chunkEventsStream;
    final message = _ImageLoadMessage(
      id: id,
      cacheKey: cacheKey,
      hivePath: hivePath,
      boxKey: boxKey,
      url: url,
    );
    _commands.send(message);
    return completer.future;
  }

  static Future<_Worker> spawn() async {
    // Create a receive port and add its initial message handler
    final initPort = RawReceivePort();
    final connection = Completer<_ConnectionData>();
    initPort.handler = (initialMessage) {
      connection.complete(_ConnectionData(
        receivePort: ReceivePort.fromRawReceivePort(initPort),
        sendPort: initialMessage,
      ));
    };

    // Spawn the isolate.
    try {
      await Isolate.spawn(_startRemoteIsolate, initPort.sendPort);
    } on Object {
      initPort.close();
      rethrow;
    }

    final connectionData = await connection.future;
    return _Worker._(connectionData.receivePort, connectionData.sendPort);
  }

  _Worker._(this._responses, this._commands) {
    _responses.listen(_handleResponsesFromIsolate);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    if (message is _ChunkEventMessage) {
      final chunkEvents = _chunkEvents[message.id]!;
      chunkEvents.add(ImageChunkEvent(
        cumulativeBytesLoaded: message.cumulative,
        expectedTotalBytes: message.total,
      ));
      return;
    }

    final response = message as _ImageLoadResponse;
    final completer = _activeRequests.remove(response.id)!;
    _chunkEvents.remove(response.id)!;
    if (response.data is RemoteError) {
      completer.completeError(response.data!);
    } else {
      completer.complete(response.data as Uint8List);
    }

    if (_closed && _activeRequests.isEmpty) _responses.close();
  }

  static void _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
  ) {
    receivePort.listen((message) async {
      if (message == 'shutdown') {
        receivePort.close();
        return;
      }
      final loadMessage = message as _ImageLoadMessage;
      try {
        final Uri resolved = Uri.base.resolve(loadMessage.url);

        final httpClient = HttpClient()..autoUncompress = false;

        final HttpClientRequest request = await httpClient.getUrl(resolved);

        final HttpClientResponse response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          await response.drain<List<int>>(<int>[]);
          throw NetworkImageLoadException(statusCode: response.statusCode, uri: resolved);
        }

        final Uint8List bytes = await consolidateHttpClientResponseBytes(
          response,
          onBytesReceived: (int cumulative, int? total) {
            sendPort.send(_ChunkEventMessage(
              id: loadMessage.id,
              cumulative: cumulative,
              total: total,
            ));
          },
        );
        if (bytes.lengthInBytes == 0) {
          throw Exception('NetworkImage is an empty file: $resolved');
        }
        final decrypted = await imageDecrypt(bytes);

        try {
          Hive.init(loadMessage.hivePath);
          final cacheBox = await Hive.openLazyBox(loadMessage.boxKey);
          await cacheBox.put(loadMessage.cacheKey, decrypted);
        } catch (_) {}

        sendPort.send(_ImageLoadResponse(id: loadMessage.id, data: decrypted));
      } catch (e) {
        sendPort.send(_ImageLoadResponse(
          id: loadMessage.id,
          data: RemoteError(e.toString(), ''),
        ));
      }
    });
  }

  static void _startRemoteIsolate(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(receivePort, sendPort);
  }

  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');
      if (_activeRequests.isEmpty) _responses.close();
    }
  }
}
