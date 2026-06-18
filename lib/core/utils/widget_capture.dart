import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 把被 RepaintBoundary 包裹的 widget 渲染成 PNG 字节。
///
/// [key] 是挂在 RepaintBoundary 上的 GlobalKey;[pixelRatio] 控制清晰度
/// (>1 更高清,代价是图更大,3.0 适合导出分享图)。
/// 返回 null 表示还没渲染好(极少见,通常是调用时机过早)。
Future<Uint8List?> captureBoundaryToPng(
  GlobalKey key, {
  double pixelRatio = 3.0,
}) async {
  final boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return null;

  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}
