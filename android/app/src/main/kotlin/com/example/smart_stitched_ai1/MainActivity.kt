package com.example.smart_stitched_ai1

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.graphics.Color

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        window.statusBarColor = Color.parseColor("#0F172A")
        window.navigationBarColor = Color.parseColor("#0F172A")
        super.onCreate(savedInstanceState)
    }
}