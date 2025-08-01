# Flutter File Generator Script

This Dart script streamlines the process of generating Flutter `controller` and `binding` files directly from your terminal. It automatically creates the necessary folders and Dart files with boilerplate code tailored for a GetX-based architecture.

## 📁 Directory Structure

The script generates files within your `lib/` folder:

```
lib/
├── controller/
│   └── your_name_controller.dart
└── binding/
    └── your_name_binding.dart
```

## 🚀 How to Use

### 1. Place the Script
Place the `make.dart` script in a `tool/` folder at the root of your Flutter project:

```
project_name/
├── lib/
│   ├── controller/
│   └── binding/
├── tool/
│   └── make.dart
```

### 2. Run the Script
From the root of your project, run the script using the terminal:

```bash
dart tool/make.dart controller:home
```

This creates:

```
lib/controller/home_controller.dart
```

```bash
dart tool/make.dart binding:home
```

This creates:

```
lib/binding/home_binding.dart
```

## 💡 How It Works

- **`controller:name`**  
  Generates `lib/controller/name_controller.dart` with a class named `NameController`.
  
- **`binding:name`**  
  Generates `lib/binding/name_binding.dart` with a class named `NameBinding` and configures `Get.lazyPut`.

- **Folder Creation**: Folders are automatically created if they don't exist.  
- **File Protection**: Existing files are not overwritten.

## 🧪 Example

```bash
dart tool/make.dart controller:auth
```

Creates:

```dart
// lib/controller/auth_controller.dart
import 'package:get/get.dart';

class AuthController extends GetxController {
  // TODO: Implement AuthController
}
```

```bash
dart tool/make.dart binding:auth
```

Creates:

```dart
// lib/binding/auth_binding.dart
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}
```

## 🧩 Optional: PowerShell Alias (Windows Only)

To simplify usage, you can create a PowerShell alias:

1. Open your PowerShell profile:

```powershell
notepad $PROFILE
```

2. Add the following function:

```powershell
function makecontroller {
    param([string]$arg)
    dart "tool/make.dart" $arg
}
```

3. Restart your terminal and use:

```bash
makecontroller controller:xyz
```

## 🧑‍💻 Author

Made with ❤️ by AkalankaKaushalya