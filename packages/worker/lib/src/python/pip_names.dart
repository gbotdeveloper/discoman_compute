/// Imports whose pip package has a different name. Anything not listed is
/// installed under its import name.
const _pipNames = {
  'PIL': 'Pillow',
  'cv2': 'opencv-python',
  'sklearn': 'scikit-learn',
  'skimage': 'scikit-image',
  'yaml': 'PyYAML',
  'bs4': 'beautifulsoup4',
  'dateutil': 'python-dateutil',
  'docx': 'python-docx',
  'pptx': 'python-pptx',
  'dotenv': 'python-dotenv',
  'Crypto': 'pycryptodome',
  'serial': 'pyserial',
  'usb': 'pyusb',
  'fitz': 'PyMuPDF',
  'magic': 'python-magic',
  'jwt': 'PyJWT',
  'git': 'GitPython',
  'attr': 'attrs',
  'google': 'protobuf',
  'win32api': 'pywin32',
  'win32com': 'pywin32',
  'mpl_toolkits': 'matplotlib',
  'Bio': 'biopython',
  'OpenGL': 'PyOpenGL',
  'wx': 'wxPython',
  'zmq': 'pyzmq',
  'Levenshtein': 'python-Levenshtein',
  'tensorflow_hub': 'tensorflow-hub',
};

/// The pip package that provides the top-level [module].
String pipPackageFor(String module) => _pipNames[module] ?? module;

/// The pip packages for [modules], each once, in order.
List<String> pipPackagesFor(Iterable<String> modules) =>
    {for (final module in modules) pipPackageFor(module)}.toList();
