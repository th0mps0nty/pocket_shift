import AVFoundation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var audioPlayer: AVAudioPlayer?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "com.tylerthompson.pocket_shift/sound_effects",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "playCoinLanding" else {
        result(FlutterMethodNotImplemented)
        return
      }

      self?.playCoinLanding()
      result(nil)
    }
  }

  private func playCoinLanding() {
    guard let privateFrameworksPath = Bundle.main.privateFrameworksPath else {
      return
    }

    let assetPath = URL(fileURLWithPath: privateFrameworksPath)
      .appendingPathComponent("App.framework")
      .appendingPathComponent("flutter_assets")
      .appendingPathComponent("assets/audio/coin_ching.wav")

    do {
      audioPlayer = try AVAudioPlayer(contentsOf: assetPath)
      audioPlayer?.volume = 0.8
      audioPlayer?.prepareToPlay()
      audioPlayer?.play()
    } catch {
      // Sound failure should not affect the app.
    }
  }
}
