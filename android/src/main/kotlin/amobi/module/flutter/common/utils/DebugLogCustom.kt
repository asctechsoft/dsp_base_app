package amobi.module.flutter.common.utils

import amobi.module.flutter.common.configs.CommFigs
import amobi.module.flutter.common.utils.DebugLogCustom.EMOJI.ARROW
import amobi.module.flutter.common.utils.DebugLogCustom.EMOJI.CHAIN
import amobi.module.flutter.common.utils.DebugLogCustom.EMOJI.DOWN_ARROW
import amobi.module.flutter.common.utils.DebugLogCustom.EMOJI.FUNCTION
import amobi.module.flutter.common.utils.DebugLogCustom.EMOJI.LOG
import amobi.module.flutter.common.utils.DebugLogCustom.EMOJI.ROBOT
import android.util.Log
import java.io.PrintWriter
import java.io.StringWriter
import kotlin.math.ceil

fun debugLogTrace(
    obj: Any?,
    fromTrace: Int = 5,
    endTrace: Int = 10,
    tag: String = "fatalLogTest",
) {
    DebugLogCustom.logMultiStackTrace(obj, fromTrace, endTrace, tag)
}

fun dlog(
    obj: Any?,
    fromTrace: Int = 5,
    endTrace: Int = 6,
    tag: String = "fatalLogTest",
) {
    DebugLogCustom.logMultiStackTrace(obj, fromTrace, endTrace, tag)
}

fun debugLog(
    obj: Any?,
    fromTrace: Int = 5,
    endTrace: Int = 6,
    tag: String = "fatalLogTest",
) {
    DebugLogCustom.logMultiStackTrace(obj, fromTrace, endTrace, tag)
}

object DebugLogCustom {
    private const val MAX_LENGTH = 3000

    private object EMOJI {
        const val ROBOT = "🤖"
        const val FUNCTION = "⚙\uFE0F"
        const val ARROW = "➡\uFE0F"
        const val DOWN_ARROW = "⬇\uFE0F"
        const val LOG = "\uD83D\uDCDD"
        const val CHAIN = "⛓\uFE0F"
    }

    fun logMultiStackTrace(
        obj: Any?,
        fromTrace: Int = 4,
        endTrace: Int = 9,
        tag: String = "fatalLogTest",
    ) {
        if (CommFigs.IS_PROD_RELEASE) return
        val message = obj.toString()

        if (!CommFigs.IS_DEBUG) {
            val fullClassName = Thread.currentThread().stackTrace[fromTrace].className
            var className = fullClassName.substring(fullClassName.lastIndexOf(".") + 1)
            if (className.contains("$"))
                className = className.split("$")[0]
            if (className.endsWith("Kt"))
                className = className.dropLast(2)
            val methodNameAbove =
                Thread
                    .currentThread()
                    .stackTrace
                    .getOrNull(fromTrace + 1)
                    ?.methodName ?: ""
            val methodName = Thread.currentThread().stackTrace[fromTrace].methodName
            val lineNumber = Thread.currentThread().stackTrace[fromTrace].lineNumber
            println("$tag $ROBOT$className.kt:$lineNumber${EMOJI.FUNCTION}[$methodNameAbove$ARROW$methodName]$LOG$message")
            return
        }

        if (message.length > MAX_LENGTH) {
            val fullClassName = Thread.currentThread().stackTrace[fromTrace].className
            var className = fullClassName.substring(fullClassName.lastIndexOf(".") + 1)
            if (className.contains("$"))
                className = className.split("$")[0]
            if (className.endsWith("Kt"))
                className = className.dropLast(2)

            val methodNameAbove =
                Thread
                    .currentThread()
                    .stackTrace
                    .getOrNull(fromTrace + 1)
                    ?.methodName ?: ""
            val methodName = Thread.currentThread().stackTrace[fromTrace].methodName
            val lineNumber = Thread.currentThread().stackTrace[fromTrace].lineNumber
            val x = ceil(message.length / MAX_LENGTH.toDouble()).toInt()
            for (i in 0 until x) {
                val start = i * MAX_LENGTH
                val end = minOf((i + 1) * MAX_LENGTH, message.length)
                val substring = message.substring(start, end)
                Log.d(tag, "$ROBOT$className.kt:$lineNumber$FUNCTION[$methodNameAbove$ARROW$methodName]$LOG$substring")
            }
            return
        }

        val traceSize =
            if (endTrace < 0)
                Thread.currentThread().stackTrace.size
            else
                endTrace

        if (traceSize - fromTrace <= 1) {
            val fullClassName = Thread.currentThread().stackTrace[fromTrace].className
            var className = fullClassName.substring(fullClassName.lastIndexOf(".") + 1)
            if (className.contains("$"))
                className = className.split("$")[0]
            if (className.endsWith("Kt"))
                className = className.dropLast(2)
            val methodNameAbove =
                Thread
                    .currentThread()
                    .stackTrace
                    .getOrNull(fromTrace + 1)
                    ?.methodName ?: ""
            val methodName = Thread.currentThread().stackTrace[fromTrace].methodName
            val lineNumber = Thread.currentThread().stackTrace[fromTrace].lineNumber
            Log.d(tag, "$ROBOT$className.kt:$lineNumber$FUNCTION[$methodNameAbove$ARROW$methodName]$LOG$message")
            return
        }

        var stackTrace = ""
        for (i in fromTrace until traceSize) {
            val fullClassName = Thread.currentThread().stackTrace[i].className
            var className = fullClassName.substring(fullClassName.lastIndexOf(".") + 1)
            if (className.contains("$"))
                className = className.split("$")[0]
            if (className.endsWith("Kt"))
                className = className.dropLast(2)
            val methodName = Thread.currentThread().stackTrace[i].methodName
            val lineNumber = Thread.currentThread().stackTrace[i].lineNumber

            stackTrace = "$className.kt:$lineNumber $FUNCTION $methodName $DOWN_ARROW\n$stackTrace"
        }
        Log.d(tag, "$ROBOT(${CHAIN}Trace: $fromTrace $ARROW $traceSize)\n$stackTrace$LOG$message")
    }

    fun logd(
        obj: Any?,
        tag: String = "fatalLogTest",
    ) {
        if (CommFigs.IS_PROD_RELEASE) return
        val message = obj.toString()
        val fullClassName = Thread.currentThread().stackTrace[4].className
        var className = fullClassName.substring(fullClassName.lastIndexOf(".") + 1)
        if (className.contains("$"))
            className = className.split("$")[0]
        if (className.endsWith("Kt"))
            className = className.dropLast(2)

        val methodNameAbove =
            Thread
                .currentThread()
                .stackTrace
                .getOrNull(5)
                ?.methodName ?: ""
        val methodName = Thread.currentThread().stackTrace[4].methodName
        val lineNumber = Thread.currentThread().stackTrace[4].lineNumber

        if (CommFigs.IS_DEBUG) {
            if (message.length <= MAX_LENGTH) {
                Log.d(tag, "$ROBOT$className.kt:$lineNumber$FUNCTION[$methodNameAbove$ARROW$methodName]$LOG$message")
            } else {
                val x = ceil(message.length / MAX_LENGTH.toDouble()).toInt()
                for (i in 0 until x) {
                    val start = i * MAX_LENGTH
                    val end = minOf((i + 1) * MAX_LENGTH, message.length)
                    val substring = message.substring(start, end)
                    Log.d(tag, "$ROBOT$className.kt:$lineNumber$FUNCTION[$methodName] $substring")
                }
            }
        } else {
            println("$tag $ROBOT$className.kt:$lineNumber$FUNCTION[$methodNameAbove$ARROW$methodName]$LOG$message")
        }
    }

    fun logn(obj: Any?) {
        if (CommFigs.IS_PROD_RELEASE) return
        val message = obj.toString()
        val fullClassName = Thread.currentThread().stackTrace[3].className
        var className = fullClassName.substring(fullClassName.lastIndexOf(".") + 1)
        if (className.contains("$"))
            className = className.split("$")[0]
        if (className.endsWith("Kt"))
            className = className.dropLast(2)

        val methodName = Thread.currentThread().stackTrace[3].methodName
        val lineNumber = Thread.currentThread().stackTrace[3].lineNumber
        Log.i("fatalLogTest", "$ROBOT$className.kt:$lineNumber$FUNCTION[$methodName]$LOG$message")
    }

    fun loge(obj: Any?) {
        if (CommFigs.IS_PROD_RELEASE) return
        val message = obj.toString()
        val fullClassName = Thread.currentThread().stackTrace[3].className
        var className = fullClassName.substring(fullClassName.lastIndexOf(".") + 1)
        if (className.contains("$"))
            className = className.substring(0, className.lastIndexOf("$"))
        if (className.endsWith("Kt"))
            className = className.dropLast(2)

        val methodName = Thread.currentThread().stackTrace[3].methodName
        val lineNumber = Thread.currentThread().stackTrace[3].lineNumber
        Log.e("fatalLogTest", "$ROBOT$className.kt:$lineNumber$FUNCTION[$methodName]$LOG$message")
    }

    fun loge(e: Exception?) {
        if (!CommFigs.IS_SHOW_TEST_OPTION || e == null) return
        val errors = StringWriter()
        e.printStackTrace(PrintWriter(errors))
        val message = errors.toString()
        val fullClassName = Thread.currentThread().stackTrace[3].className
        var className = fullClassName.substring(fullClassName.lastIndexOf(".") + 1)
        if (className.contains("$"))
            className = className.substring(0, className.lastIndexOf("$"))
        if (className.endsWith("Kt"))
            className = className.dropLast(2)

        val methodName = Thread.currentThread().stackTrace[3].methodName
        val lineNumber = Thread.currentThread().stackTrace[3].lineNumber
        Log.e("fatalLogTest", "$ROBOT$className.kt:$lineNumber$FUNCTION[$methodName]$LOG$message")
    }

    fun logi(obj: Any?) {
        if (CommFigs.IS_PROD_RELEASE) return
        val message = obj.toString()
        val fullClassName = Thread.currentThread().stackTrace[3].className
        var className = fullClassName.substring(fullClassName.lastIndexOf(".") + 1)
        if (className.contains("$"))
            className = className.substring(0, className.lastIndexOf("$"))
        if (className.endsWith("Kt"))
            className = className.dropLast(2)

        val methodName = Thread.currentThread().stackTrace[3].methodName
        val lineNumber = Thread.currentThread().stackTrace[3].lineNumber
        Log.i("fatalLogTest", "$ROBOT$className.kt:$lineNumber$FUNCTION[$methodName]$LOG$message")
    }
}
