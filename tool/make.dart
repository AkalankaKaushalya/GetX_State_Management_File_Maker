import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty || !arguments[0].contains(':')) {
    print("❌ Usage: dart tool/make.dart [controller|binding]:[name]");
    return;
  }

  final parts = arguments[0].split(':');
  if (parts.length != 2) {
    print("❌ Invalid format. Use: category:filename");
    return;
  }

  final category = parts[0].trim(); // controller or binding
  final filename = parts[1].trim(); // e.g., location_check

  final directory = Directory('lib/$category');
  final className = _toPascalCase("${filename}_$category");
  final filePath = 'lib/$category/${filename}_$category.dart';

  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
    print("📁 Created folder: ${directory.path}");
  }

  final file = File(filePath);
  if (file.existsSync()) {
    print("⚠️ File already exists: $filePath");
    return;
  }

  // Generate controller or binding content
  String content;

  if (category == "controller") {
    content = '''
import 'package:get/get.dart';

class ${_toPascalCase(filename)}Controller extends GetxController {
  // TODO: Implement ${_toPascalCase(filename)}Controller
}
''';
  } else if (category == "binding") {
    content = '''
import 'package:get/get.dart';
import '../controller/${filename}_controller.dart';

class ${_toPascalCase(filename)}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ${_toPascalCase(filename)}Controller());
  }
}
''';
  } else {
    print("❌ Unsupported category: $category");
    return;
  }

  file.writeAsStringSync(content);
  print("✅ Created: $filePath");
}

String _toPascalCase(String text) {
  return text.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join();
}
