module engine.core;

public:
import engine.core.engine;
import engine.core.ext_data;
import engine.core.hal;
import engine.core.input;
import engine.core.math;
import engine.core.mod;
import engine.core.multithreading;
import engine.core.object;
import engine.core.resource;
import engine.core.serialize;
import engine.core.utils;
import engine.core.vfs;

void initCore() {
    log.info( getSystemInfo().toString() );

    CModuleManager.get().add( new CCoreResourcesModule() );
    CModuleManager.get().add( new CInputModule() );
}