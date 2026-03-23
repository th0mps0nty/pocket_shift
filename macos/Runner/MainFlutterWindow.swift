import AVFoundation
import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var audioPlayer: AVAudioPlayer?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    configureSoundChannel(flutterViewController)

    super.awakeFromNib()
  }

  private func configureSoundChannel(_ flutterViewController: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "com.tylerthompson.pocket_shift/sound_effects",
      binaryMessenger: flutterViewController.engine.binaryMessenger
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
      .appendingPathComponent("Resources/flutter_assets")
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
