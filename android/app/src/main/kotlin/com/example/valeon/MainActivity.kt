package com.app.valeon

import android.content.pm.PackageManager
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import java.security.MessageDigest

class MainActivity : FlutterActivity() {
    
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        printFacebookKeyHash()
    }
    
    private fun printFacebookKeyHash() {
        try {
            val info = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
            } else {
                packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
            }
            
            val signatures = when {
                android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P -> 
                    info.signingInfo?.apkContentsSigners
                else -> 
                    info.signatures
            }
            
            signatures?.forEach { signature ->
                val md = MessageDigest.getInstance("SHA")
                md.update(signature.toByteArray())
                val keyHash = String(Base64.encode(md.digest(), 0))
                Log.d("FacebookKeyHash:", keyHash)
                println("🔐 Facebook Key Hash: $keyHash")
            }
            
        } catch (e: Exception) {
            e.printStackTrace()
            println("❌ Erreur: ${e.message}")
        }
    }
}