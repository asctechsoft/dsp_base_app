#include <jni.h>

#ifndef STRINGIFY
#define STRINGIFY_HELPER(x) #x
#define STRINGIFY(x) STRINGIFY_HELPER(x)
#endif


extern "C" JNIEXPORT jstring JNICALL
Java_amobi_module_flutter_common_configs_UtilitiesNdk_validatorNative(JNIEnv *env, jobject object) {
    return env->NewStringUTF(STRINGIFY(APP_CHECK));
}

extern "C" JNIEXPORT jstring JNICALL
Java_amobi_module_flutter_common_configs_UtilitiesNdk_secretTokenNative(JNIEnv *env, jobject object) {
    return env->NewStringUTF(STRINGIFY(SECRET_TOKEN));
}
