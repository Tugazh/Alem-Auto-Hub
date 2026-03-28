import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:o3d/o3d.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';

class _O3DGate {
  static int _active = 0;
  static const int _max = 20;
  static final List<Completer<void>> _queue = [];

  static Future<void> acquire() async {
    if (_active < _max) {
      _active++;
      return;
    }

    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
    _active++;
  }

  static void release() {
    if (_active > 0) {
      _active--;
    }
    if (_queue.isNotEmpty) {
      final next = _queue.removeAt(0);
      if (!next.isCompleted) {
        next.complete();
      }
    }
  }
}

/// Виджет для отображения 3D модели автомобиля (GLB формат)
class Car3DViewer extends StatefulWidget {
  final String? model3dUrl;
  final String? fallbackImageUrl;
  final String carName;
  final String? cameraOrbit;
  final bool cameraControls;
  final bool autoActivate;

  const Car3DViewer({
    super.key,
    this.model3dUrl,
    this.fallbackImageUrl,
    required this.carName,
    this.cameraOrbit,
    this.cameraControls = true,
    this.autoActivate = true,
  });

  @override
  State<Car3DViewer> createState() => _Car3DViewerState();
}

class _RawCameraOrbit implements CameraOrbit {
  final String raw;
  _RawCameraOrbit(this.raw);

  @override
  double get theta => 0;
  @override
  set theta(double v) {}

  @override
  double get phi => 0;
  @override
  set phi(double v) {}

  @override
  double get radius => 0;
  @override
  set radius(double v) {}

  @override
  String toString() => raw;
}

class _Car3DViewerState extends State<Car3DViewer> {
  O3DController? _controller;
  bool _isReady = false;
  bool _checkingAsset = true;
  bool _assetAvailable = true;
  Timer? _initDebounce;
  bool _hasError = false;
  String? _localPath; // cached local file or asset path
  bool _isCaching = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoActivate) {
      _prepareModel();
    } else {
      _checkingAsset = false;
      _isCaching = false;
      _isReady = false;
    }
  }

  @override
  void didUpdateWidget(Car3DViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoActivate &&
        !oldWidget.autoActivate &&
        !_isReady &&
        !_isCaching) {
      setState(() {
        _checkingAsset = true;
      });
      _prepareModel();
    } else if (!widget.autoActivate && oldWidget.autoActivate) {
      // Release 3D engine aggressively to save memory when not active
      _initDebounce?.cancel();
      if (_isReady) {
        _O3DGate.release();
      }
      setState(() {
        _controller = null;
        _isReady = false;
        _checkingAsset = false;
        _isCaching = false;
      });
    }
  }

  Future<void> _prepareModel() async {
    final source = widget.model3dUrl;
    if (source == null || source.isEmpty) {
      setState(() {
        _assetAvailable = false;
        _checkingAsset = false;
        _hasError = true;
      });
      return;
    }

    // Asset bundled with app
    if (source.startsWith('assets/')) {
      try {
        await rootBundle.load(source);
        if (!mounted) return;
        setState(() {
          _localPath = source;
          _assetAvailable = true;
          _checkingAsset = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _assetAvailable = false;
          _checkingAsset = false;
          _hasError = true;
        });
      }
      _initDebounce = Timer(const Duration(milliseconds: 80), _initViewer);
      return;
    }

    // Remote URL: cache to disk for faster next launches
    setState(() {
      _isCaching = true;
      _checkingAsset = true;
      _hasError = false;
    });

    try {
      final dir = await getApplicationSupportDirectory();
      final cacheDir = Directory('${dir.path}/o3d_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final safeName = base64UrlEncode(utf8.encode(source)).replaceAll('=', '');
      final filePath = '${cacheDir.path}/$safeName.glb';
      final file = File(filePath);

      if (!await file.exists()) {
        HttpClient? client;
        try {
          client = HttpClient();
          final uri = Uri.parse(source);
          final request = await client.getUrl(uri);
          final response = await request.close();
          if (response.statusCode != 200) {
            throw Exception('HTTP ${response.statusCode}');
          }
          final bytes = await consolidateHttpClientResponseBytes(response);
          await file.writeAsBytes(bytes, flush: true);
        } finally {
          client?.close(force: true);
        }
      }

      if (!mounted) return;
      setState(() {
        _localPath = file.path;
        _assetAvailable = true;
        _checkingAsset = false;
        _isCaching = false;
      });
      _initDebounce = Timer(const Duration(milliseconds: 80), _initViewer);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _assetAvailable = false;
        _checkingAsset = false;
        _isCaching = false;
        _hasError = true;
      });
    }
  }

  Future<void> _initViewer() async {
    await _O3DGate.acquire();
    if (!mounted) {
      _O3DGate.release();
      return;
    }

    setState(() {
      _controller = O3DController();
      _isReady = true;
    });
  }

  @override
  void dispose() {
    _initDebounce?.cancel();
    if (_isReady) {
      _O3DGate.release();
    }
    super.dispose();
  }

  CameraOrbit? _parseCameraOrbit(String? orbit) {
    if (orbit == null || orbit.isEmpty) return null;
    return _RawCameraOrbit(orbit);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || !_assetAvailable || widget.model3dUrl == null) {
      return _errorBox('3D модель недоступна');
    }

    // Если автозапуск выключен (например авто сбоку в карусели) — не грузим и не рисуем саму о3д модель пока не станет активной
    if (!widget.autoActivate) {
      return const SizedBox.shrink();
    }

    if (_checkingAsset ||
        _isCaching ||
        !_isReady ||
        _controller == null ||
        _localPath == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final src = _localPath!;
    final resolvedSrc =
        src.startsWith('assets/') ? src : Uri.file(src).toString();
    return RepaintBoundary(
      child: O3D.asset(
        key: ValueKey(resolvedSrc),
        src: resolvedSrc,
        controller: _controller!,
        ar: false,
        autoPlay: false,
        autoRotate: false,
        cameraOrbit: _parseCameraOrbit(widget.cameraOrbit),
        cameraControls: widget.cameraControls,
      ),
    );
  }

  Widget _errorBox(String title) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
