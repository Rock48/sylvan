module terrain.camera;
import gl3n.linalg;

struct Camera {
    vec2i tilePos;
    vec2  tileDim;
    vec2i screenDim;
    vec2i screenTileDim;
}
