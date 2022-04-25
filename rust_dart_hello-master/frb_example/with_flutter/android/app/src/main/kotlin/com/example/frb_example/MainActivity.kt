package com.example.frb_example

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import android.util.Base64.DEFAULT
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.goterl.lazysodium.LazySodiumAndroid
import com.goterl.lazysodium.SodiumAndroid
import com.goterl.lazysodium.interfaces.Sign
import com.goterl.lazysodium.utils.Key
import com.goterl.lazysodium.utils.KeyPair
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.IvParameterSpec


class MainActivity: FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/getkey"
    var lazySodium = LazySodiumAndroid(SodiumAndroid())

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            // Note: this method is invoked on the main thread.
            if (call.method == "getKey1") {
                var pub = readData("PublicKey")
                result.success(pub)
            }else if (call.method == "getKey2"){
                var pub = readData("PublicKey2")
                result.success(pub)
            }else if(call.method == "sign"){
                val message = call.argument<String>("message")
                var pub = readData("PublicKey")
                var priv = readData("PrivateKey")
                var kp = KeyPair(Key.fromBase64String(pub as String?),Key.fromBase64String(priv as String?))
                var signature = message?.let { sign(kp, it, lazySodium) }
                result.success(signature)
            }else if(call.method == "generateKeys"){
                var x = generateNewKeys()
                result.success(x)
            }else if(call.method == "verify"){
                val message = call.argument<String>("message")
                val signature = call.argument<String>("signature")
                val key = call.argument<String>("key")
                var res = verify(key!!, message!!, lazySodium, signature!!)
                result.success(res);
            }
            else {
                result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        //var lazySodium = LazySodiumAndroid(SodiumAndroid())
        val keyPair : KeyPair

        if(!checkAESKeyExists()){
            createAESKey()
        }

        if(readData("PublicKey") == false){
            val keyPair by lazy {
                lazySodium.cryptoSignKeypair().apply {
                    val newKeyPair = this
                }
            }
            val keyPair2 by lazy {
                lazySodium.cryptoSignKeypair().apply {
                    val newKeyPair2 = this
                }
            }
            var x = getPublicKey(keyPair)
            writeData("PublicKey", x)
            var y = getPrivateKey(keyPair)
            writeData("PrivateKey", y)
            var x2 = getPublicKey(keyPair2)
            writeData("PublicKey2", x2)
            var y2 = getPrivateKey(keyPair2)
            writeData("PrivateKey2", y2)
        }
        var pub = readData("PublicKey")
        var priv = readData("PrivateKey")
        var kp = KeyPair(Key.fromBase64String(pub as String?),Key.fromBase64String(priv as String?))
        //var sig = sign(kp, keriText, lazySodium)
        //println("the signature is $sig")

    }

    fun getPublicKey(keyPair: KeyPair) = Base64.encodeToString(keyPair.publicKey.asBytes, Base64.NO_WRAP)
    fun getPrivateKey(keyPair: KeyPair) = Base64.encodeToString(keyPair.secretKey.asBytes, Base64.NO_WRAP)

    private fun generateNewKeys() :String{
        var pub = readData("PublicKey")
        println("old pubkey: $pub")

        var pub2 = readData("PublicKey2")
        println("second pubkey: $pub2")

        var priv2 = readData("PrivateKey2")
        writeData("PublicKey", pub2.toString())
        writeData("PrivateKey", priv2.toString())
        pub = readData("PublicKey")
        println("second pubkey as now first: $pub")


        val keyPair2 by lazy {
            lazySodium.cryptoSignKeypair().apply {
                val newKeyPair2 = this
            }
        }
        var x2 = getPublicKey(keyPair2)
        writeData("PublicKey2", x2)
        var y2 = getPrivateKey(keyPair2)
        writeData("PrivateKey2", y2)

        pub2 = readData("PublicKey2")
        println("second pubkey new: $pub2")
        return "x"
    }

    fun sign(keyPair: KeyPair, text: String, lazySodium: LazySodiumAndroid): String? {
        val messageBytes: ByteArray = lazySodium.bytes(text)
        val signedMessage: ByteArray = lazySodium.randomBytesBuf(Sign.BYTES)
        val res: String? = lazySodium.cryptoSignDetached(
            text, keyPair.secretKey
        )
        if (res != null) {
            println("the result is ${res}")
        }
        print("podpis w b64: ${Base64.encodeToString(signedMessage, Base64.NO_WRAP)}")
        return res
        //return Base64.encodeToString(signedMessage, Base64.NO_WRAP)
    }

    fun verify(
        key : String,
        message: String,
        lazySodium: LazySodiumAndroid,
        signature: String
    ): Boolean {
        return lazySodium.cryptoSignVerifyDetached(
            signature, message, Key.fromBase64String(key)
        )
        //return true
    }


    private fun writeData(key: String, data: String){
        try{
            val encryptedData = encrypt(data)
            val sharedPref = getPreferences(Context.MODE_PRIVATE) ?: return
            with (sharedPref.edit()) {
                putString(key, encryptedData)
                apply()
            }
        }catch (e: Exception){
            println("Something went wrong")
        }
    }

    private fun readData(key: String): Any {
        val sharedPref = getPreferences(Context.MODE_PRIVATE)
        val textToRead : String? = sharedPref.getString(key, null)
        if(textToRead.isNullOrEmpty()){
            return false
        }else{
            val userData = decrypt(textToRead)
            if(userData != null){
                return userData
            }
            return false
        }
    }

    private fun deleteData(key: String){
        val sharedPref = getPreferences(Context.MODE_PRIVATE) ?: return
        with (sharedPref.edit()) {
            remove(key)
            apply()
        }
    }


    //FUNCTION TO ENCRYPT DATA WHEN WRITTEN INTO STORAGE
    private fun encrypt(strToEncrypt: String) :  String? {
        try
        {
            val keyStore: KeyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply {
                load(null)
            }
            //We get the aes key from the keystore if they exists
            val secretKey = keyStore.getKey(ANDROID_AES_ALIAS, null) as SecretKey
            var result = ""
            val cipher = Cipher.getInstance("AES/CBC/PKCS7Padding")
            cipher.init(Cipher.ENCRYPT_MODE, secretKey)
            val iv = cipher.iv
            val ivString = Base64.encodeToString(iv, Base64.DEFAULT)
            result += Base64.encodeToString(cipher.doFinal(strToEncrypt.toByteArray(Charsets.UTF_8)), Base64.DEFAULT)
            result += IV_SEPARATOR + ivString
            return result
        }
        catch (e: Exception) {
        }
        return null
    }

    //FUNCTION TO DECRYPT DATA WHEN READ FROM STORAGE
    private fun decrypt(strToDecrypt : String) : String? {
        try{
            val split = strToDecrypt.split(IV_SEPARATOR.toRegex())
            val keyStore: KeyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply {
                load(null)
            }
            val ivString = split[1]
            val encodedData = split[0]
            //We get the aes key from the keystore if they exists
            val secretKey = keyStore.getKey(ANDROID_AES_ALIAS, null) as SecretKey
            val ivSpec = IvParameterSpec(Base64.decode(ivString, DEFAULT))
            val cipher = Cipher.getInstance("AES/CBC/PKCS7Padding")

            cipher.init(Cipher.DECRYPT_MODE, secretKey, ivSpec)
            return  String(cipher.doFinal(Base64.decode(encodedData, Base64.DEFAULT)))
        }catch (e: Exception) {
        }
        return null
    }

    //FUNCTION TO CREATE AES KEY FOR ENCRYPTION AND DECRYPTION
    private fun createAESKey() {
        val keyGenerator = KeyGenerator.getInstance(
            KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore"
        )
        keyGenerator.init(
            KeyGenParameterSpec.Builder(
                ANDROID_AES_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_CBC)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_PKCS7)
                .build()
        )
        keyGenerator.generateKey()
    }

    //FUNCTION TO CHECK IF KEY FOR ENCRYPTION AND DECRYPTION EXISTS
    private fun checkAESKeyExists() :Boolean{
        val keyStore: KeyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply {
            load(null)
        }
        //We get the aes key from the keystore if they exists
        val secretKey = keyStore.getKey(ANDROID_AES_ALIAS, null) as SecretKey?
        return secretKey != null
    }
}



private const val ANDROID_KEYSTORE = "AndroidKeyStore"
//ENCRYPT/DECRYPT KEY ALIAS
private const val ANDROID_AES_ALIAS = "UserAESKey"
//IV STRING SEPARATOR
private const val IV_SEPARATOR = ";"
