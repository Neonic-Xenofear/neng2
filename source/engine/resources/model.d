module engine.resources.model;

import engine.core.resource;
import engine.resources.mesh;

class CModel {
protected:
    CMesh[] meshes;

public:
    void addMesh( CMesh mesh ) {
        import std.algorithm : canFind;

        if ( checkResValid( mesh ) && !meshes.canFind( mesh ) ) {
            meshes ~= mesh;
        }
    }

    void removeMesh( CMesh mesh ) {
        import engine.core.utils.array : removeElement;
        meshes.removeElement( mesh );
    }
}