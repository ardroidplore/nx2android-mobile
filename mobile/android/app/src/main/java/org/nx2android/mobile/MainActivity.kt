package org.nx2android.mobile

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.graphics.Typeface
import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast

class MainActivity : Activity() {
    private lateinit var gamePath: EditText
    private lateinit var keysPath: EditText
    private lateinit var outputPath: EditText

    private fun dp(v: Int) = (v * resources.displayMetrics.density).toInt()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val scroll = ScrollView(this)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(20), dp(28), dp(20), dp(24))
        }
        scroll.addView(root)
        setContentView(scroll)

        root.addView(TextView(this).apply {
            text = "nx2android Mobile"
            textSize = 26f
            typeface = Typeface.DEFAULT_BOLD
        })
        root.addView(TextView(this).apply {
            text = "Port game dump → build Android APK\nExperimental controller for the original nx2android engine."
            textSize = 14f
            setPadding(0, dp(8), 0, dp(20))
        })

        gamePath = field(root, "Folder game dump", "/storage/emulated/0/SwitchDumps/Game")
        keysPath = field(root, "Path prod.keys", "/storage/emulated/0/keys/prod.keys")
        outputPath = field(root, "Folder output", "/storage/emulated/0/nx2android-output")

        val port = Button(this).apply {
            text = "Mulai porting di Termux"
            textSize = 16f
            isAllCaps = false
            setOnClickListener { launchPort() }
        }
        root.addView(port, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(54)).apply { topMargin = dp(16) })

        root.addView(TextView(this).apply {
            text = "Prasyarat: jalankan mobile/scripts/setup-termux.sh satu kali di Termux. Aktifkan Allow external apps di pengaturan Termux. Build belum tervalidasi di perangkat; simpan dump dan keys milik sendiri."
            textSize = 12f
            setPadding(0, dp(18), 0, 0)
        })
    }

    private fun field(parent: LinearLayout, label: String, hint: String): EditText {
        parent.addView(TextView(this).apply {
            text = label
            textSize = 14f
            typeface = Typeface.DEFAULT_BOLD
            setPadding(0, dp(12), 0, dp(4))
        })
        val edit = EditText(this).apply {
            setSingleLine(true)
            textSize = 14f
            setText(hint)
            gravity = Gravity.CENTER_VERTICAL
            selectAllOnFocus = true
        }
        parent.addView(edit, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(52)))
        return edit
    }

    private fun launchPort() {
        val game = gamePath.text.toString().trim()
        val keys = keysPath.text.toString().trim()
        val out = outputPath.text.toString().trim()
        if (game.isBlank() || keys.isBlank() || out.isBlank()) {
            Toast.makeText(this, "Isi semua path terlebih dahulu", Toast.LENGTH_LONG).show()
            return
        }
        val intent = Intent("com.termux.RUN_COMMAND").apply {
            setClassName("com.termux", "com.termux.app.RunCommandService")
            putExtra("com.termux.RUN_COMMAND_PATH", "/data/data/com.termux/files/usr/bin/bash")
            putExtra("com.termux.RUN_COMMAND_ARGUMENTS", arrayOf(
                "/storage/emulated/0/nx2android-mobile/mobile/scripts/termux-port.sh", game, keys, out
            ))
            putExtra("com.termux.RUN_COMMAND_WORKDIR", "/data/data/com.termux/files/home")
            putExtra("com.termux.RUN_COMMAND_BACKGROUND", false)
        }
        try {
            startService(intent)
            Toast.makeText(this, "Perintah dikirim ke Termux. Lihat sesi Termux untuk progres.", Toast.LENGTH_LONG).show()
        } catch (e: SecurityException) {
            Toast.makeText(this, "Izin RUN_COMMAND belum diberikan. Aktifkan Allow external apps dan izinkan permission Termux.", Toast.LENGTH_LONG).show()
        } catch (e: ActivityNotFoundException) {
            Toast.makeText(this, "Termux tidak ditemukan. Instal Termux dan selesaikan setup.", Toast.LENGTH_LONG).show()
        } catch (e: Exception) {
            Toast.makeText(this, "Gagal menjalankan Termux: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }
}
