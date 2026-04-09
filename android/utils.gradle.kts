import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec
import java.util.regex.Pattern
import java.util.Base64

val algorithm = "AES/CBC/PKCS5Padding"
val iv = ByteArray(16) { 0 }
val ivSpec = IvParameterSpec(iv)

extra["encrypt"] = { text: String, key: String ->
    val cipher = Cipher.getInstance(algorithm)
    cipher.init(Cipher.ENCRYPT_MODE, SecretKeySpec(key.toByteArray(), "AES"), ivSpec)
    val cipherText = cipher.doFinal(text.toByteArray())
    Base64.getEncoder().encodeToString(cipherText)
}

extra["getCurrentFlavor"] = fun(): String {
    val gradle = gradle
    val tskReqStr = gradle.startParameter.taskRequests.toString()

    val pattern = when {
        tskReqStr.contains("assemble") -> Pattern.compile("assemble(\\w+)(Release|Debug)")
        tskReqStr.contains("bundle") -> Pattern.compile("bundle(\\w+)(Release|Debug)")
        else -> Pattern.compile("generate(\\w+)(Release|Debug)")
    }

    val matcher = pattern.matcher(tskReqStr)

    return if (matcher.find()) {
        matcher.group(1).lowercase()
    } else {
        println("NO MATCH FLAVOR FOUND")
        ""
    }
}

extra["getCurrentVariant"] = fun(): String {
    val gradle = gradle
    val tskReqStr = gradle.startParameter.taskRequests.toString()

    val pattern = when {
        tskReqStr.contains("assemble") -> Pattern.compile("assemble(\\w+)(Release|Debug)")
        tskReqStr.contains("bundle") -> Pattern.compile("bundle(\\w+)(Release|Debug)")
        else -> Pattern.compile("generate(\\w+)(Release|Debug)")
    }

    val matcher = pattern.matcher(tskReqStr)

    return if (matcher.find()) {
        matcher.group(2).lowercase()
    } else {
        println("NO MATCH VARIANT FOUND")
        ""
    }
}

