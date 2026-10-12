// Prepara le immagini dell'icona dell'app e dell'icona delle notifiche
// dal logo del circolo.
//
//   dart run tool/make_launcher_icon.dart
//   dart run flutter_launcher_icons
//
// L'icona delle notifiche Android deve essere bianca su trasparente: le
// parti colorate dello stemma diventano bianche, quelle bianche (lettere,
// bordi) trasparenti, così le lettere restano leggibili in negativo.
//
// Il logo è verticale: lo centriamo su un quadrato. Per l'icona adattiva di
// Android il logo sta nella zona sicura (66% centrale), perché il sistema
// ritaglia i bordi a cerchio o a goccia.
import 'dart:io';

import 'package:image/image.dart' as img;

const _logo = 'assets/brand/crpadel_logo.png';
const _size = 1024;

/// Icona delle notifiche: 24 dp per densità.
const _notificationSizes = {
  'mdpi': 24,
  'hdpi': 36,
  'xhdpi': 48,
  'xxhdpi': 72,
  'xxxhdpi': 96,
};

void main() {
  final logo = img.decodePng(File(_logo).readAsBytesSync())!;
  _write('assets/brand/app_icon.png', _square(logo, 0.86, opaque: true));
  _write(
    'assets/brand/app_icon_foreground.png',
    _square(logo, 0.60, opaque: false),
  );
  final stencil = _stencil(logo);
  for (final MapEntry(key: density, value: px) in _notificationSizes.entries) {
    final icon = img.Image(width: px, height: px, numChannels: 4);
    // Lo stemma è verticale: occupa tutta l'altezza, centrato.
    final height = px;
    final width = (stencil.width * height / stencil.height).round();
    img.compositeImage(
      icon,
      img.copyResize(
        stencil,
        width: width,
        height: height,
        interpolation: img.Interpolation.average,
      ),
      dstX: (px - width) ~/ 2,
    );
    _write(
      'android/app/src/main/res/drawable-$density/ic_notification.png',
      icon,
    );
  }
}

/// Parti scure o colorate → bianco pieno; parti chiare → trasparente.
/// Ritaglia il margine bianco attorno allo stemma.
img.Image _stencil(img.Image logo) {
  var (left, top, right, bottom) = (logo.width, logo.height, 0, 0);
  final out = img.Image(width: logo.width, height: logo.height, numChannels: 4);
  for (final p in logo) {
    if (p.luminanceNormalized < 0.75) {
      out.setPixelRgba(p.x, p.y, 255, 255, 255, 255);
      if (p.x < left) left = p.x;
      if (p.x > right) right = p.x;
      if (p.y < top) top = p.y;
      if (p.y > bottom) bottom = p.y;
    } else {
      out.setPixelRgba(p.x, p.y, 0, 0, 0, 0);
    }
  }
  return img.copyCrop(
    out,
    x: left,
    y: top,
    width: right - left + 1,
    height: bottom - top + 1,
  );
}

/// Logo centrato su un quadrato, alto [ratio] del lato.
img.Image _square(img.Image logo, double ratio, {required bool opaque}) {
  final canvas = img.Image(width: _size, height: _size, numChannels: 4);
  img.fill(
    canvas,
    color: opaque
        ? img.ColorRgba8(255, 255, 255, 255)
        : img.ColorRgba8(0, 0, 0, 0),
  );
  final height = (_size * ratio).round();
  final width = (logo.width * height / logo.height).round();
  final scaled = img.copyResize(
    logo,
    width: width,
    height: height,
    interpolation: img.Interpolation.cubic,
  );
  img.compositeImage(
    canvas,
    scaled,
    dstX: (_size - width) ~/ 2,
    dstY: (_size - height) ~/ 2,
  );
  return canvas;
}

void _write(String path, img.Image image) {
  File(path).writeAsBytesSync(img.encodePng(image));
  stdout.writeln('Scritto $path');
}
