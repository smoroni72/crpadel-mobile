// Prepara le immagini dell'icona dell'app dal logo del circolo.
//
//   dart run tool/make_launcher_icon.dart
//   dart run flutter_launcher_icons
//
// Il logo è verticale: lo centriamo su un quadrato. Per l'icona adattiva di
// Android il logo sta nella zona sicura (66% centrale), perché il sistema
// ritaglia i bordi a cerchio o a goccia.
import 'dart:io';

import 'package:image/image.dart' as img;

const _logo = 'assets/brand/crpadel_logo.png';
const _size = 1024;

void main() {
  final logo = img.decodePng(File(_logo).readAsBytesSync())!;
  _write('assets/brand/app_icon.png', _square(logo, 0.86, opaque: true));
  _write(
    'assets/brand/app_icon_foreground.png',
    _square(logo, 0.60, opaque: false),
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
