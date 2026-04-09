import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.FileInputStream
import java.util.Properties
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec
import java.util.Base64
import java.util.regex.Pattern

group = "amobi.module.flutter.common"
version = "1.0-SNAPSHOT"

val firebaseCoreProject = findProject(":firebase_core")
val firebaseAppCheckProject = findProject(":firebase_app_check")

fun getRootProjectExtOrCoreProperty(name: String, firebaseCoreProject: Project?): String? {
    val flutterFire = rootProject.extensions.findByName("FlutterFire") as? Map<*, *>
    val value =
        flutterFire?.get(name) ?: return firebaseCoreProject?.properties?.get(name) as? String
    return value as? String
}

apply(from = file("utils.gradle.kts"))

buildscript {
    val kotlinVersion = "2.1.0"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.13.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "amobi.module.flutter.common"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlin {
        compilerOptions {
            jvmTarget = JvmTarget.JVM_11
        }
    }

    val debugKeystorePropertiesFile = rootProject.file("debug_keystore.properties")
    val debugKeystoreProperties = Properties()
    debugKeystoreProperties.load(FileInputStream(debugKeystorePropertiesFile))
    var appCheckToken = debugKeystoreProperties["appCheckToken"] as? String ?: ""
    val appCheckKey = debugKeystoreProperties["appCheckKey"] as? String ?: ""

    val secretToken = debugKeystoreProperties.getOrDefault("secretToken", "amobi") as String
    val secretKey = debugKeystoreProperties.getOrDefault("secretKey", "1234567890abcdef") as String

    val getCurrentVariant = extra["getCurrentVariant"] as () -> String
    val getCurrentFlavor = extra["getCurrentFlavor"] as () -> String
    val encrypt = extra["encrypt"] as (String, String) -> String

    val variant = getCurrentVariant()
    val isDebug = variant == "debug"
    val flavor = getCurrentFlavor()

    println("currentFlavor: $flavor")
    println("currentVariant: $variant")

    if (flavor == "product") {
        val productKeyPath = debugKeystoreProperties["productKeyPath"] as? String
        if (productKeyPath != null) {
            val keystorePropertiesFile = rootProject.file(productKeyPath)
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                appCheckToken = keystoreProperties["appCheckToken"] as? String ?: ""
            } else {
                throw GradleException(
                    "Product keystore file not found: ${keystorePropertiesFile.absolutePath}\n" +
                            "This file is required to build Product release variants.\n" +
                            "Please ensure the keystore file exists or build a different variant (Dev/Alpha)."
                )
            }
        }
    }

    // Note: generated source dir is added in afterEvaluate {} below,
    // AFTER flavor/variant are resolved, to avoid empty-path conflicts.

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }

        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24

        if (firebaseAppCheckProject != null) {
            externalNativeBuild {
                cmake {
                    arguments("-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON")

                    val encrypt = extra["encrypt"] as? (String, String) -> String
                    val encryptedAppCheck = encrypt?.invoke(appCheckToken, appCheckKey) ?: ""
                    val encryptedSecretToken = encrypt?.invoke(secretToken, secretKey) ?: ""

                    cppFlags("-DAPP_CHECK=\\\"$encryptedAppCheck\\\"")
                    cppFlags("-DSECRET_TOKEN=\\\"$encryptedSecretToken\\\"")
                }
            }
        }
    }


    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.22.1"
        }
    }


}

dependencies {
    if (firebaseCoreProject != null) {
        api(firebaseCoreProject)
        val firebaseSdkVersion = getRootProjectExtOrCoreProperty("FirebaseSDKVersion", firebaseCoreProject)
        compileOnly(platform("com.google.firebase:firebase-bom:$firebaseSdkVersion"))
        compileOnly("com.google.firebase:firebase-appcheck-debug")
        compileOnly("com.google.firebase:firebase-appcheck-playintegrity")
    }

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")

    testImplementation("org.jetbrains.kotlin:kotlin-test")
}

afterEvaluate {
    // Get flavor and variant from the android block
    val getCurrentVariant = extra["getCurrentVariant"] as () -> String
    val getCurrentFlavor = extra["getCurrentFlavor"] as () -> String
    val variant = getCurrentVariant()
    val isDebug = variant == "debug"
    val flavor = getCurrentFlavor()
    
    // Generate Kotlin constants file for build config flags.
    // Use a FIXED output path (not flavor-dependent) to avoid conflicting
    // declarations when Gradle evaluates afterEvaluate for multiple variants.
    // Only one file is generated — for the ACTIVE variant.
    val buildConfigOutputDir = file("${project.buildDir}/generated/source/buildConfig/kotlin/active")
    android.sourceSets.getByName("main").java.srcDirs(buildConfigOutputDir)
    val outputFile = file("${buildConfigOutputDir}/configs/BuildConfigConstants.kt")

    // Clean stale flavor-specific dirs that may conflict
    val staleRoot = file("${project.buildDir}/generated/source/buildConfig/kotlin")
    staleRoot.listFiles()?.filter { it.isDirectory && it.name != "active" }?.forEach { it.deleteRecursively() }

    // Load properties for keys
    val debugKeystorePropertiesFile = rootProject.file("debug_keystore.properties")
    val debugKeystoreProperties = Properties()
    debugKeystoreProperties.load(FileInputStream(debugKeystorePropertiesFile))
    val appCheckKey = debugKeystoreProperties["appCheckKey"] as? String ?: ""
    val secretKey = debugKeystoreProperties.getOrDefault("secretKey", "1234567890abcdef") as String

    val generateBuildConfigConstants = tasks.register("generateBuildConfigConstants") {
        outputs.file(outputFile)
        outputs.upToDateWhen { false } // Always regenerate

        doLast {
            buildConfigOutputDir.mkdirs()
            outputFile.parentFile.mkdirs()

            val isAlpha = flavor == "alpha"
            val isDev = flavor == "dev"
            val isProduct = flavor == "product"

            // Escape the appCheckKey string for Kotlin code generation
            val escapedAppCheckKey = appCheckKey.replace("\\", "\\\\").replace("\"", "\\\"")
            val escapedSecretKey = secretKey.replace("\\", "\\\\").replace("\"", "\\\"")

            outputFile.writeText("""
package amobi.module.flutter.common.configs

// Auto-generated file - do not edit manually
// Generated at build time based on variant: $variant
// Generated at build time based on flavor: $flavor

// Top-level const vals that can be referenced as const val in other files
const val AMOBI_CONFIG_IS_ALPHA = $isAlpha
const val AMOBI_CONFIG_IS_DEV = $isDev
const val AMOBI_CONFIG_IS_PRODUCT = $isProduct
const val AMOBI_CONFIG_IS_DEBUG = $isDebug
const val AMOBI_CONFIG_APP_CHECK_KEY = "$escapedAppCheckKey"
const val AMOBI_CONFIG_SECRET_KEY = "$escapedSecretKey"
""".trimIndent())
        }
    }
    
    // Make all Kotlin compile tasks depend on code generation
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        dependsOn(generateBuildConfigConstants)
    }
    
    // Also ensure it runs before preBuild
    tasks.named("preBuild").configure {
        dependsOn(generateBuildConfigConstants)
    }
    
    if (firebaseCoreProject != null) {
        android.sourceSets.named("main").configure {
            if (file("src/firebase/kotlin").exists()) {
                java.srcDirs("src/firebase/kotlin")
            }
            if (file("src/firebase/res").exists()) {
                res.srcDirs("src/firebase/res")
            }
        }
    } else {
        android.sourceSets.named("main").configure {
            java.exclude("**/firebase/**")
            resources.exclude("**/firebase/**")
        }
    }
}

