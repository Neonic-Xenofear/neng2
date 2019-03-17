module engine.app.logger;

import std.experimental.logger;
import std.stdio : File;
import std.concurrency : Tid;
import std.datetime : SysTime;

import engine.core.utils.singleton;

public import std.experimental.logger : LogLevel;
public import std.stdio : stdout;

class CLogger : FileLogger {
    // Cache instantiation flag in thread-local bool
    // Thread local
    static bool bInstantiated;

    // Thread global
    __gshared CLogger inst;

public:
    static CLogger get() {
        if ( !bInstantiated ) {
            synchronized ( CLogger.classinfo ) {
                if ( !inst ) {
                    inst = new CLogger( stdout, LogLevel.all );
                }

                bInstantiated = true;
            }
        }

        return inst;
    }

    // See this list: https://wiki.archlinux.org/index.php/Color_Bash_Prompt#List_of_colors_for_prompt_and_Bash
    enum Color : string
    {
        Clear  = "\033c",  // clear console
        Normal = "\033[0m",  // reset color
        Black  = "\033[1;30m",
        Red    = "\033[1;31m",
        Green  = "\033[1;32m",
        Yellow = "\033[1;33m",
        Blue   = "\033[1;34m",
        Purple = "\033[1;35m",
        Cyan   = "\033[1;36m",
        White  = "\033[1;37m"
    }


  private:
    immutable string[LogLevel] _colorMap;


  public:
    this(File file, const LogLevel lv = LogLevel.info) @safe
    {
        this(file, null, lv);
    }

    this(File file, in string[LogLevel] colorMap, const LogLevel lv = LogLevel.info) @safe
    {
        super(file, lv);
        _colorMap = buildColorMap(colorMap);
    }

    override protected void beginLogMsg(string file, int line, string funcName,
                                        string prettyFuncName, string moduleName, LogLevel logLevel,
                                        Tid threadId, SysTime timestamp, Logger logger) @safe
    {

        this.file.lockingTextWriter().put(_colorMap[logLevel]);
        super.beginLogMsg(file, line, funcName, prettyFuncName, moduleName, logLevel, threadId, timestamp, logger);
    }

    override protected void finishLogMsg()
    {
        auto lt = this.file.lockingTextWriter();
        lt.put(cast(string)Color.Normal);
        lt.put('\n');
        this.file.flush();
    }


  private:
    immutable(string[LogLevel]) buildColorMap(in string[LogLevel] colorMap) @trusted pure
    {
        import std.exception : assumeUnique;
        import std.traits : EnumMembers;

        string[LogLevel] result;

        foreach (ll; EnumMembers!LogLevel) {
            if (ll in colorMap) {
                result[ll] = colorMap[ll];
                continue;
            }

            // Default color mapping
            final switch (ll) {
            case LogLevel.all, LogLevel.off:
                break;
            case LogLevel.trace:
                result[ll] = Color.Blue;
                break;
            case LogLevel.info:
                result[ll] = Color.Green;
                break;
            case LogLevel.warning:
                result[ll] = Color.Yellow;
                break;
            case LogLevel.error:
                result[ll] = Color.Purple;
                break;
            case LogLevel.critical:
                result[ll] = Color.Red;
                break;
            case LogLevel.fatal:
                result[ll] = Color.Cyan;
                break;
            }
        }

        return result.assumeUnique;
    }
}

CLogger log() {
    return CLogger.get();
}