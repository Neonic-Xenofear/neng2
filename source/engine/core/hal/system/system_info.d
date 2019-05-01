module engine.core.hal.system.system_info;

struct SCPUInfo {
    string name;

    uint stepping;
    uint coresCount;
    size_t[5] cachesSize;
}

/**
    Some usefull system info
*/
struct SSystemInfo {
    ulong totalRam;
    ulong freeRam;

    SCPUInfo cpuInfo;

    string toString() {
        import std.conv : to;
        return 
            "\nSystem Info:" ~
            "\n\tRam: " ~ to!string( totalRam / ( 1024 * 1024 ) ) ~ " MB" ~
            "\n\n\tCPU info:" ~
            "\n\t\tName: " ~ cpuInfo.name ~
            "\n\t\tStepping: " ~ to!string( cpuInfo.stepping ) ~
            "\n\t\tCores count: " ~ to!string( cpuInfo.coresCount );
    }
}

private __gshared SSystemInfo __systemInfo;

private void updateSystemInfo() {
    SSystemInfo procInfo;

    version( Windows ) {
        import core.sys.windows.windows;
        MEMORYSTATUSEX memStat;
        memStat.dwLength = memStat.sizeof;
        GlobalMemoryStatusEx( &memStat );
        
        procInfo.totalRam = memStat.ullTotalPhys;
    }

    version( linux ) {
        import core.sys.linux.sys.sysinfo;
        sysinfo_ lInfo;
        sysinfo( &lInfo );

        procInfo.totalRam = lInfo.totalram;
        procInfo.freeRam = lInfo.freeram;
    }

    {
        import core.cpuid;
        
        SCPUInfo cpuInfo;

        cpuInfo.name = processor();
        cpuInfo.stepping = stepping;
        cpuInfo.coresCount = coresPerCPU();
        for ( int i = 0; i < dataCaches().length; i++ ) {
            cpuInfo.cachesSize[i] = dataCaches()[i].size;
        }

        procInfo.cpuInfo = cpuInfo;
    }

    __systemInfo = procInfo;
}

SSystemInfo getSystemInfo() {
    updateSystemInfo();
    return __systemInfo;
}