module engine.core.ext_data.ext_data_manager;

public import engine.core.ext_data.ext_data;

interface IExtDataManager {
    void initData( CExtData data );
    void destroyData( CExtData data );

    CExtData cloneData( CExtData data );
}