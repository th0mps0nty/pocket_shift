package com.tylerthompson.pocket_shift

import android.media.AudioAttributes
import android.media.SoundPool
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var soundPool: SoundPool? = null
    private var soundId: Int = 0

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        initializeSoundPool()

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.tylerthompson.pocket_shift/sound_effects"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "playCoinLanding" -> {
                    playCoinLanding()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeSoundPool() {
        if (soundPool != null) {
            return
        }

        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        soundPool = SoundPool.Builder()
            .setMaxStreams(1)
            .setAudioAttributes(attributes)
            .build()

        soundId = soundPool?.load(assets.openFd("flutter_assets/assets/audio/coin_ching.wav"), 1) ?: 0
    }

    private fun playCoinLanding() {
        if (soundId == 0) {
            initializeSoundPool()
        }
        soundPool?.play(soundId, 0.85f, 0.85f, 1, 0, 1.0f)
    }

    override fun onDestroy() {
        soundPool?.release()
        soundPool = null
        super.onDestroy()
    }
}
