module engine.render.commands.render_mesh_commands;

import engine.core.utils.envelope;
import engine.resources.mesh;

struct SRenderGenMeshData {
    SEnvelope!CMesh mesh;
}

struct SRenderDestroyMeshData {
    SEnvelope!CMesh mesh;
}

struct SRenderDestroyMeshDataEnd {}