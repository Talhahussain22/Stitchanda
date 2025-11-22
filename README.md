📘 **README – Stitchanda Multi-Application Flutter Project**
============================================================

This repository contains **three independent Flutter applications**, each developed as part of the Stitchanda ecosystem:

1.  **Stitchanda Customer Application**
    
2.  **Stitchanda Tailor Application**
    
3.  **Stitchanda Driver Application**
    

Each application uses a **different Flutter SDK version**, managed through **FVM (Flutter Version Management)** to ensure consistency and prevent version conflicts across environments.

This document provides a **complete installation and setup guide** for running all three applications on a new system, including manual Flutter installation, Android Studio configuration, FVM setup, and execution steps.

📌 **1\. System Requirements**
==============================

*   **Operating System:** Windows 10 or later
    
*   **RAM:** Minimum 8 GB (16 GB recommended)
    
*   **Disk Space:** 10 GB+
    
*   **Tools Required:**
    
    *   Git
        
    *   Visual Studio Code
        
    *   Android Studio (with SDK + Emulator)
        
    *   Flutter SDK (manual installation)
        
    *   FVM (Flutter Version Manager)
        

📦 **2\. Installation Guide (For a Completely New System)**
===========================================================

The following steps must be completed before running any of the Stitchanda applications.

🔹 **2.1 Install Git**
----------------------

Download and install from:[https://git-scm.com/downloads](https://git-scm.com/downloads)

Use default installation settings.

🔹 **2.2 Install Visual Studio Code**
-------------------------------------

Download from:[https://code.visualstudio.com/](https://code.visualstudio.com/)

After installation, open VS Code → Extensions → Install:

*   **Flutter**
    
*   **Dart**
    

🔹 **2.3 Install Android Studio (Includes Android SDK & Emulator)**
-------------------------------------------------------------------

Download Android Studio:[https://developer.android.com/studio](https://developer.android.com/studio)

During installation, ensure the following components are selected:

*   Android SDK
    
*   Android SDK Platform
    
*   Android SDK Build-tools
    
*   Android Virtual Device
    
*   Android SDK Command-line Tools
    

After installation:

### Open **Android Studio → More Actions → SDK Manager**

Ensure the following are installed:

*   Android API 34 (or latest stable)
    
*   Android SDK Platform Tools
    
*   Android SDK Build Tools
    
*   Android Emulator
    

🔹 **2.4 Install Flutter SDK (Manual Installation)**
----------------------------------------------------

_(This is required even though FVM will manage versions.)_

1.  Download Flutter from the official website:https://flutter.dev/docs/get-started/install
    
2.  Extract the Flutter SDK to a location such as:
    

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   C:\src\flutter   `

1.  Add Flutter to the system PATH:
    

*   Open **Environment Variables**
    
*   Select **Path**
    
*   Add:
    

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   C:\src\flutter\bin   `

1.  Restart terminal and verify:
    

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   flutter --version   `

🔹 **2.5 Run Flutter Doctor**
-----------------------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   flutter doctor   `

Fix any missing items (especially Android toolchain).

📦 **3\. FVM (Flutter Version Management) Setup**
=================================================

The Stitchanda project uses multiple Flutter versions.FVM ensures each app uses its correct version automatically.

🔹 **3.1 Install FVM**
----------------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   dart pub global activate fvm   `

### Add FVM to PATH:

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   C:\Users\\AppData\Local\Pub\Cache\bin   `

Verify installation:

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   fvm --version   `

▶️ 4**. Running the Applications**
==================================

Each application is isolated and must be run individually.

🔹 4**.1 Run Stitchanda Customer Application**
----------------------------------------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   cd stitchanda_customer  fvm install  fvm flutter pub get  fvm flutter run   `

🔹 4**.2 Run Stitchanda Tailor Application**
--------------------------------------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   cd stitchanda_tailor  fvm install  fvm flutter pub get  fvm flutter run   `

🔹 4**.3 Run Stitchanda Driver Application**
--------------------------------------------

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   cd stitchanda_driver  fvm install  fvm flutter pub get  fvm flutter run   `

📌 5**. Notes**
===============

### ✔ Manual Flutter installation is required

Even though FVM manages SDKs per project, the base Flutter installation is needed for:

*   Dart & Flutter toolchain detection
    
*   Android Studio integration
    
*   VS Code Flutter extension support
    

### ✔ FVM reads .fvmrc automatically

FVM installs and uses the correct Flutter version for each app.

### ✔ Running in VS Code

Open **each app folder separately** in VS Code.Do _not_ open the main root folder containing all apps.

🧪 6**. Troubleshooting**
=========================

### ❗ FVM command not found

Add this path:

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   C:\Users\\AppData\Local\Pub\Cache\bin   `

Restart terminal.

### ❗ Emulator not detected

Open Android Studio → Device Manager → Create a new virtual device.

### ❗ Build errors

Run:

Plain textANTLR4BashCC#CSSCoffeeScriptCMakeDartDjangoDockerEJSErlangGitGoGraphQLGroovyHTMLJavaJavaScriptJSONJSXKotlinLaTeXLessLuaMakefileMarkdownMATLABMarkupObjective-CPerlPHPPowerShell.propertiesProtocol BuffersPythonRRubySass (Sass)Sass (Scss)SchemeSQLShellSwiftSVGTSXTypeScriptWebAssemblyYAMLXML`   fvm flutter clean  fvm flutter pub get   `
