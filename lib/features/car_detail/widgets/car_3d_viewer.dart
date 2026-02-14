import 'dart:async';
import 'package:flutter/material.dart';
import 'package:o3d/o3d.dart';
import '../../../core/theme/app_colors.dart';

class _O3DGate {
  static int _active = 0;
  static const int _max = 1;
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

  const Car3DViewer({
    super.key,
    this.model3dUrl,
    this.fallbackImageUrl,
    required this.carName,
    this.cameraOrbit,
    this.cameraControls = true,
  });

  @override
  State<Car3DViewer> createState() => _Car3DViewerState();
}

class _Car3DViewerState extends State<Car3DViewer> {
  O3DController? _controller;
  bool _isReady = false;
  Timer? _initDebounce;

  @override
  void initState() {
    super.initState();
    _initDebounce = Timer(const Duration(milliseconds: 300), _initViewer);
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

  @override
  Widget build(BuildContext context) {
    if (widget.model3dUrl == null || widget.model3dUrl!.isEmpty) {
      return _buildFallback();
    }

    if (!_isReady || _controller == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Загрузка 3D модели...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return O3D.asset(
      src: widget.model3dUrl!,
      controller: _controller!,
      ar: false,
      autoPlay: false,
      autoRotate: false,
      cameraControls: widget.cameraControls,
    );
  }

  Widget _buildFallback() {
    if (widget.fallbackImageUrl != null) {
      return Image.network(
        widget.fallbackImageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildIcon(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
    return _buildIcon();
  }

  Widget _buildIcon() {
    return Icon(
      Icons.directions_car,
      size: 100,
      color: AppColors.iconGray.withValues(alpha: 0.15),
    );
  }
}
