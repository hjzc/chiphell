import Flutter
import UIKit

//UIScene https://docs.flutter.dev/release/breaking-changes/uiscenedelegate#create-a-scenedelegate-optional
@main
@objc class AppDelegate: FlutterAppDelegate ,FlutterImplicitEngineDelegate{
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
   //GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Register plugins with `engineBridge.pluginRegistry`
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // // Create method channels with `engineBridge.applicationRegistrar.messenger()`
    // let batteryChannel = FlutterMethodChannel(
    //   name: "samples.flutter.dev/battery",
    //   binaryMessenger: engineBridge.applicationRegistrar.messenger()
    // )

    // // Create platform views with `engineBridge.applicationRegistrar.messenger()`
    // let factory = FLNativeViewFactory(messenger: engineBridge.applicationRegistrar.messenger())

  }


}

//private func registerPlugins(registry: FlutterPluginRegistry) {
//    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
//       FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
//    }
//}
