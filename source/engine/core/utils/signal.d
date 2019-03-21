module engine.core.utils.signal;

import std.signals;

struct SSignal( T1... ) {
        static import core.exception;
    static import core.stdc.stdlib;
    /***
     * A slot is implemented as a delegate.
     * The slot_t is the type of the delegate.
     * The delegate must be to an instance of a class or an interface
     * to a class instance.
     * Delegates to struct instances or nested functions must not be
     * used as slots.
     */
    alias slot_t = void delegate(T1);

    /***
     * Call each of the connected slots, passing the argument(s) i to them.
     * Nested call will be ignored.
     */
    final void emit( T1 i )
    {
        if (status >= ST.inemitting || !slots.length)
            return; // should not nest

        status = ST.inemitting;
        scope (exit)
            status = ST.idle;

        foreach (slot; slots[0 .. slots_idx])
        {   if (slot)
                slot(i);
        }

        assert(status >= ST.inemitting);
        if (status == ST.inemitting_disconnected)
        {
            for (size_t j = 0; j < slots_idx;)
            {
                if (slots[j] is null)
                {
                    slots_idx--;
                    slots[j] = slots[slots_idx];
                }
                else
                    j++;
            }
        }
    }

    /***
     * Add a slot to the list of slots to be called when emit() is called.
     */
    final void connect(slot_t slot)
    {
        /* Do this:
         *    slots ~= slot;
         * but use malloc() and friends instead
         */
        auto len = slots.length;
        if (slots_idx == len)
        {
            if (slots.length == 0)
            {
                len = 4;
                auto p = core.stdc.stdlib.calloc(slot_t.sizeof, len);
                if (!p)
                    core.exception.onOutOfMemoryError();
                slots = (cast(slot_t*) p)[0 .. len];
            }
            else
            {
                import core.checkedint : addu, mulu;
                bool overflow;
                len = addu(mulu(len, 2, overflow), 4, overflow); // len = len * 2 + 4
                const nbytes = mulu(len, slot_t.sizeof, overflow);
                if (overflow) assert(0);

                auto p = core.stdc.stdlib.realloc(slots.ptr, nbytes);
                if (!p)
                    core.exception.onOutOfMemoryError();
                slots = (cast(slot_t*) p)[0 .. len];
                slots[slots_idx + 1 .. $] = null;
            }
        }
        slots[slots_idx++] = slot;

     L1:
        Object o = _d_toObject(slot.ptr);
        rt_attachDisposeEvent(o, &unhook);
    }

    /***
     * Remove a slot from the list of slots to be called when emit() is called.
     */
    final void disconnect(slot_t slot)
    {
        debug (signal) writefln("Signal.disconnect(slot)");
        size_t disconnectedSlots = 0;
        size_t instancePreviousSlots = 0;
        if (status >= ST.inemitting)
        {
            foreach (i, sloti; slots[0 .. slots_idx])
            {
                if (sloti.ptr == slot.ptr &&
                    ++instancePreviousSlots &&
                    sloti == slot)
                {
                    disconnectedSlots++;
                    slots[i] = null;
                    status = ST.inemitting_disconnected;
                }
            }
        }
        else
        {
            for (size_t i = 0; i < slots_idx; )
            {
                if (slots[i].ptr == slot.ptr &&
                    ++instancePreviousSlots &&
                    slots[i] == slot)
                {
                    slots_idx--;
                    disconnectedSlots++;
                    slots[i] = slots[slots_idx];
                    slots[slots_idx] = null;        // not strictly necessary
                }
                else
                    i++;
            }
        }

         // detach object from dispose event if all its slots have been removed
        if (instancePreviousSlots == disconnectedSlots)
        {
            Object o = _d_toObject(slot.ptr);
            rt_detachDisposeEvent(o, &unhook);
        }
     }

    /***
     * Disconnect all the slots.
     */
    final void disconnectAll()
    {
        debug (signal) writefln("Signal.disconnectAll");
        //_dtor();
        this.destroy();
        slots_idx = 0;
        status = ST.idle;
    }

    /* **
     * Special function called when o is destroyed.
     * It causes any slots dependent on o to be removed from the list
     * of slots to be called by emit().
     */
    final void unhook(Object o)
    in { assert( status == ST.idle ); }
    do
    {
        debug (signal) writefln("Signal.unhook(o = %s)", cast(void*) o);
        for (size_t i = 0; i < slots_idx; )
        {
            if (_d_toObject(slots[i].ptr) is o)
            {   slots_idx--;
                slots[i] = slots[slots_idx];
                slots[slots_idx] = null;        // not strictly necessary
            }
            else
                i++;
        }
    }

    /* **
     * There can be multiple destructors inserted by mixins.
     */
    ~this()
    {
        /* **
         * When this object is destroyed, need to let every slot
         * know that this object is destroyed so they are not left
         * with dangling references to it.
         */
        if (slots.length)
        {
            foreach (slot; slots[0 .. slots_idx])
            {
                if (slot)
                {   Object o = _d_toObject(slot.ptr);
                    rt_detachDisposeEvent(o, &unhook);
                }
            }
            core.stdc.stdlib.free(slots.ptr);
            slots = null;
        }
    }

  private:
    slot_t[] slots;             // the slots to call from emit()
    size_t slots_idx;           // used length of slots[]

    enum ST { idle, inemitting, inemitting_disconnected }
    ST status;
}