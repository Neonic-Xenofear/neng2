module engine.core.ext_data.ext_data;

public import std.variant;
public import engine.core.ext_data.ext_data_manager;

/**
    Used for sub modules generated info save
*/
class CExtData {
    /**
        Calling directly is not recommended, use the "data" functions instead
    */
    Variant m_data;
    IExtDataManager manager;

    alias m_data this;

    ~this() {
        if ( manager ) {
            manager.destroyData( this );
        }

        m_data.destroy();
    }

    /**
        Return clone of data
    */
    CExtData clone() {
        if ( manager ) {
            return manager.cloneData( this );
        }

        return null;
    }

    /**
        Return const data
    */
    @property
    const( Variant ) data() const {
        return m_data;
    }

    /**
        Set new data.
        Params:
            newData - new data.
    */
    @nogc
    @property
    void data( T )( T newData ) const {
        if ( newData is null ) {
            return;
        }

        m_data = newData;
    }

    /**
        Returns data as given type
        Params:
            T - cast type
    */
    @property
    inout( T ) as( T )() inout {
        return m_data.get!T;
    }

    /**
        Check if data has value.
    */
    bool isNull() const {
        return !m_data.hasValue();
    }
}