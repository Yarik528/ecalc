import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class NoisePainter extends CustomPainter {
  static ui.Image? _cached;

  static Future<void> precache() async {
    if (_cached != null) return;
    const size = 128;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final random = Random(42);
    final paint = Paint();
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final v = random.nextInt(255);
        paint.color = Color.fromARGB(5, v, v, v);
        canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1), paint);
      }
    }
    final picture = recorder.endRecording();
    _cached = await picture.toImage(size, size);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final image = _cached;
    if (image == null) return;
    final matrix = Float64List.fromList([
      1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1,
    ]);
    final shader = ImageShader(image, TileMode.repeated, TileMode.repeated, matrix);
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}