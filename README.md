# maxhome_europa

A program to guide robots on Europa

## Getting Started

# Running the Flutter Application Locally Using Android Studio

This guide provides detailed instructions on setting up your local environment to run the Flutter application provided for your interview assignment. It focuses on using Android Studio to install Flutter, clone the project directly from a GitHub repository, and run the application on various platforms, including web browsers and emulators.

## 1. Install Android Studio

Android Studio is the official Integrated Development Environment (IDE) for Android application development and offers robust support for Flutter development.

1. **Download Android Studio**:
    - Visit the official Android Studio download page: [https://developer.android.com/studio](https://developer.android.com/studio).
    - Download and install the latest version suitable for your operating system.

2. **Install Flutter and Dart Plugins**:
    - Open Android Studio.
    - Navigate to `Preferences` (on macOS) or `Settings` (on Windows/Linux) > `Plugins`.
    - In the `Marketplace` tab, search for `Flutter` and click `Install`. This action will also prompt you to install the Dart plugin.
    - Restart Android Studio to activate the plugins.

## 2. Install the Flutter SDK

Android Studio can assist in downloading and setting up the Flutter SDK.

1. **Initiate a New Flutter Project**:
    - Open Android Studio.
    - Select `Start a new Flutter project` from the welcome screen.
    - In the dialog that appears, click on `Install SDK` to allow Android Studio to download and set up the Flutter SDK automatically.
    - Once the SDK is installed, cancel the new project creation process, as our goal is to clone an existing project.

## 3. Clone the Project Repository from GitHub

You can clone the Flutter project directly within Android Studio.

1. **Open the Version Control System (VCS) Menu**:
    - In Android Studio, navigate to `VCS` > `Get from Version Control`.

2. **Enter Repository Details**:
    - In the dialog that appears:
        - **Version Control**: Select `Git`.
        - **URL**: Enter the GitHub repository URL provided for your assignment.
        - **Directory**: Choose the local directory where you want to store the project.
    - Click `Clone` to initiate the cloning process.

## 4. Open the Cloned Project in Android Studio

1. **Open the Project**:
    - Once cloning is complete, Android Studio may prompt you to open the project. If not, navigate to `File` > `Open`, and select the cloned project's directory.

2. **Configure the Flutter SDK Path**:
    - If prompted, provide the path to the Flutter SDK. If Android Studio installed it for you, the path is typically set automatically. You can verify or set it by navigating to `File` > `Settings` (on Windows/Linux) or `Android Studio` > `Preferences` (on macOS) > `Languages & Frameworks` > `Flutter`, and specifying the SDK path.

## 5. Install Project Dependencies

1. **Open the `pubspec.yaml` File**:
    - In the Project Explorer, locate and open the `pubspec.yaml` file.

2. **Fetch Dependencies**:
    - At the top of the `pubspec.yaml` file, click on the `Pub get` button that appears. This action will fetch and install all necessary packages for the project.

## 6. Run the Application

Flutter applications can be run on various platforms, including web browsers and emulators.

### Running on an Emulator

To run the application on an Android emulator:

1. **Set Up an Android Emulator**:
    - **Enable VM Acceleration**: Ensure that Virtual Machine (VM) acceleration is enabled on your development computer.
    - **Start Android Studio**.
    - **Access AVD Manager**:
        - Navigate to `Tools` > `AVD Manager`.
    - **Create a Virtual Device**:
        - Click on `Create Virtual Device`.
        - Choose a device definition and click `Next`.
        - Select a system image (download it if necessary) and click `Next`.
        - Configure the emulator settings as desired and click `Finish`.
    - **Launch the Emulator**:
        - In the AVD Manager, click the `Play` button next to the newly created virtual device to start the emulator.

2. **Run the App on the Emulator**:
    - In Android Studio's toolbar, select the emulator as the target device.
    - Click the `Run` button (green play icon) to build and run the application on the emulator.

### Running on a Web Browser

To run the application in a web browser:

1. **Ensure Web Support is Enabled**:
    - Open the terminal in Android Studio.
    - Navigate to the project's root directory.
    - Run `flutter config --enable-web` to ensure web support is enabled.

2. **Run the App on the Web**:
    - In Android Studio's toolbar, select `Chrome (web)` or your preferred browser as the target device.
    - Click the `Run` button to build and run the application in the selected web browser.

## 7. Troubleshooting

- **Missing Dependencies**: If you encounter issues related to missing dependencies, ensure that all required plugins are installed and that you've fetched the project's dependencies as outlined in Step 5.

- **Emulator Issues**: If the emulator fails to launch or runs slowly, ensure that your system meets the necessary requirements and that VM acceleration is enabled. Refer to the official Android Emulator documentation for detailed guidance.

- **Web Platform Issues**: If the application doesn't run as expected in the web browser, ensure that your Flutter project has web support enabled. You can add web support by running `flutter create .` in the project's root directory.

- **Permission Errors**: On Unix-based systems, you might need to adjust permissions using `chmod` or run commands with `sudo`.

For more detailed guidance, refer to the official Flutter documentation: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install).

By following these steps, you should be able to set up your local environment and run the Flutter application successfully on both emulators and web browsers. 
