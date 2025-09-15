package com.company.civexam_pro

import android.os.Bundle
import androidx.emoji2.bundled.BundledEmojiCompatConfig
import androidx.emoji2.text.EmojiCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        EmojiCompat.init(BundledEmojiCompatConfig(this))
        super.onCreate(savedInstanceState)
    }
}
