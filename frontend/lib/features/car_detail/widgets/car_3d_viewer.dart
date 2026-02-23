import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _Car3DViewerState extends State<Car3DViewer> {
  O3DController? _controller;
  bool _isReady = false;
  bool _checkingAsset = true;
  bool _assetAvailable = true;
  Timer? _initDebounce;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _isActive = widget.autoActivate;
    if (_isActive) {
      _checkAssetAvailability();
      _initDebounce = Timer(const Duration(milliseconds: 150), _initViewer);
    } else {
      _checkingAsset = false;
      _assetAvailable = false;
    }
  }

  void _activate3d() {
    if (_isActive) return;
    setState(() {
      _isActive = true;
      _checkingAsset = true;
    });
    _checkAssetAvailability();
    _initDebounce = Timer(const Duration(milliseconds: 150), _initViewer);
  }

  Future<void> _checkAssetAvailability() async {
    final source = widget.model3dUrl;
    if (source == null || source.isEmpty) {
      if (!mounted) return;
      setState(() {
        _assetAvailable = false;
        _checkingAsset = false;
      });
      return;
    }

    if (source.startsWith('assets/')) {
      try {
        await rootBundle.load(source);
        if (!mounted) return;
        setState(() {
          _assetAvailable = true;
          _checkingAsset = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _assetAvailable = false;
          _checkingAsset = false;
        });
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _assetAvailable = true;
      _checkingAsset = false;
    });
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

    if (!_isActive) {
      return _buildInactive();
    }

    if (_checkingAsset) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'Проверка 3D модели...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (!_assetAvailable) {
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

    return RepaintBoundary(
      child: O3D.asset(
        key: ValueKey(widget.model3dUrl),
        src: widget.model3dUrl!,
        controller: _controller!,
        ar: false,
        autoPlay: false,
        autoRotate: false,
        cameraControls: widget.cameraControls,
      ),
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

  Widget _buildInactive() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: _buildFallback()),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextButton(
            onPressed: _activate3d,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Показать 3D'),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Icon(
      Icons.directions_car,
      size: 100,
      color: AppColors.iconGray.withValues(alpha: 0.15),
    );
  }
}
