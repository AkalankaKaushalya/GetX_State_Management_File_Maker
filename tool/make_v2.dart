import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty || !arguments[0].contains(':')) {
    print(
      "❌ Usage: dart tool/make.dart [controller|binding|screen|all]:[name]",
    );
    return;
  }

  final parts = arguments[0].split(':');
  if (parts.length != 2) {
    print("❌ Invalid format. Use: category:filename");
    return;
  }

  final category = parts[0].trim();
  final filename = parts[1].trim();
  final className = _toPascalCase(filename);

  if (category == "all") {
    _createFile("controller", filename);
    _createFile("binding", filename);
    _createFile("screens", filename);

    _updateRouter(filename, className);
    _updateInitParsersAndControllers(filename, className);
    return;
  }

  _createFile(category, filename);

  if (category == "screens") {
    _updateRouter(filename, className);
  } else if (category == "controller") {
    _updateInitParsersAndControllers(filename, className);
  }
}

void _createFile(String category, String filename) {
  final className = _toPascalCase(filename);
  final directory = Directory('lib/$category');
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

  String content = '';
  switch (category) {
    case "controller":
      content =
          '''
import 'package:get/get.dart';

class ${className}Controller extends GetxController {
  final ${className}Parser parser;

  ${className}Controller({required this.parser});
}

class ${className}Parser {}
''';
      break;

    case "binding":
      content =
          '''
import 'package:get/get.dart';
import '../controller/${filename}_controller.dart';

class ${className}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ${className}Controller(parser: Get.find()));
  }
}
''';
      break;

    case "screens":
      content =
          '''
import 'package:flutter/material.dart';

class ${className}Screen extends StatefulWidget {
  const ${className}Screen({Key? key}) : super(key: key);

  @override
  _${className}ScreenState createState() => _${className}ScreenState();
}

class _${className}ScreenState extends State<${className}Screen> {
  @override
  Widget build(BuildContext context) => const Center(child: Text('$className'));
}
''';
      break;

    default:
      print("❌ Unsupported category: $category");
      return;
  }

  file.writeAsStringSync(content);
  print("✅ Created: $filePath");
}

void _updateRouter(String filename, String className) {
  final routerFile = File('lib/router/router.dart');
  if (!routerFile.existsSync()) {
    print("❌ router.dart not found");
    return;
  }

  final importLine =
      "import 'package:ape_thanak_lk/screens/${filename}_screen.dart';\n"
      "import 'package:ape_thanak_lk/binding/${filename}_binding.dart';";
  final routeConst = "static const String ${filename}_screen = '/$filename';";
  final routeGetter =
      "static String get${className}Route() => ${filename}_screen;";
  final routePage =
      '''
    GetPage(
      name: ${filename}_screen,
      page: () => const ${className}Screen(),
      binding: ${className}Binding(),
    ),''';

  String content = routerFile.readAsStringSync();

  if (!content.contains("${filename}_screen")) {
    // Add imports
    content = content.replaceFirst(
      "import 'package:get/get.dart';",
      "import 'package:get/get.dart';\n$importLine",
    );

    // Add const
    content = content.replaceFirstMapped(
      RegExp(r'(static const String .*?;)'),
      (match) => '${match.group(1)}\n  $routeConst',
    );

    // Add getter
    content = content.replaceFirstMapped(
      RegExp(r'(static String get.*?;)'),
      (match) => '${match.group(1)}\n  $routeGetter',
    );

    // Insert GetPage inside the list before closing ]
    final routeListMatch = RegExp(
      r'static List<GetPage> routes = \[\s*([\s\S]*?)\];',
    ).firstMatch(content);

    if (routeListMatch != null) {
      final existingRoutes = routeListMatch.group(1);
      final newRoutes = '$existingRoutes\n$routePage';
      content = content.replaceRange(
        routeListMatch.start,
        routeListMatch.end,
        'static List<GetPage> routes = [\n$newRoutes\n  ];',
      );
    }

    routerFile.writeAsStringSync(content);
    print("✅ router.dart updated with new screen route");
  } else {
    print("⚠️ router.dart already contains this route");
  }
}

void _updateInitParsersAndControllers(String filename, String className) {
  final initFile = File('lib/util/init.dart');
  if (!initFile.existsSync()) {
    print("❌ init.dart not found");
    return;
  }

  String content = initFile.readAsStringSync();

  final parserLine = "Get.lazyPut(() => ${className}Parser(), fenix: true);";
  final controllerLine =
      "Get.lazyPut(() => ${className}Controller(parser: Get.find()));";

  if (!content.contains(parserLine)) {
    content = content.replaceFirstMapped(
      RegExp(r'void _registerParsers\(\) \{([\s\S]*?)\}'),
      (match) =>
          '''
void _registerParsers() {
${match.group(1)}  $parserLine
}''',
    );
    print("✅ Added parser to init.dart");
  }

  if (!content.contains(controllerLine)) {
    content = content.replaceFirstMapped(
      RegExp(r'void _registerControllers\(\) \{([\s\S]*?)\}'),
      (match) =>
          '''
void _registerControllers() {
${match.group(1)}  $controllerLine
}''',
    );
    print("✅ Added controller to init.dart");
  }

  initFile.writeAsStringSync(content);
}

String _toPascalCase(String text) {
  return text.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join();
}
