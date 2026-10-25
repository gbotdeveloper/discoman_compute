import 'package:discoman_worker/src/python/pip_names.dart';
import 'package:test/test.dart';

void main() {
  test('maps imports to the pip packages that provide them', () {
    expect(pipPackageFor('PIL'), 'Pillow');
    expect(pipPackageFor('cv2'), 'opencv-python');
    expect(pipPackageFor('numpy'), 'numpy');
  });

  test('lists each package once', () {
    expect(pipPackagesFor(['win32api', 'win32com', 'yaml']), [
      'pywin32',
      'PyYAML',
    ]);
  });
}
