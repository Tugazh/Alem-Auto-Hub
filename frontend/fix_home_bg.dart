import 'dart:io';

void main() {
  var file = File('lib/features/home/home_page.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    '''  Widget _buildCarCarouselBackground() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (_, __) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [
                Color.lerp(
                  const Color(0xFF622414),
                  const Color(0xFF7A2E1A),
                  _glowAnimation.value,
                )!,
                const Color(0xFF231411),
                const Color(0xFF161616),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        );
      },
    );
  }''',
    '''  Widget _buildCarCarouselBackground() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (_, __) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF161616),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.7 + (_glowAnimation.value * 0.3),
                  child: Image.asset(
                    'assets/images/ellipse.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }'''
  );
  file.writeAsStringSync(content);
}
