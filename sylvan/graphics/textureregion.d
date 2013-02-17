module sylvan.graphics.textureregion;
import gl3n.linalg;
import sylvan.graphics.texture;

class TextureRegion {
package:
    vec2 m_pixP1, m_pixP2;
    vec2 m_texP1, m_texP2;
    vec2 m_pixDims;
    vec2 m_texDims;
    Texture m_tex;

public:
    this() {}

    this(vec2 p1, vec2 p2, Texture tex) {
        m_pixP1 = p1;
        m_pixP2 = p2;

        m_texP1 = vec2(p1.x / tex.m_width, p1.y / tex.m_height);
        m_texP2 = vec2(p2.x / tex.m_width, p2.y / tex.m_height);

        m_pixDims = vec2(p2.x - p1.x, p2.y - p1.y);
        m_texDims = vec2(m_texP2.x - m_texP1.x, m_texP2.y - m_texP1.y);

        m_tex = tex;
    }

    @property vec2 pixP1() const { return m_pixP1; }
    @property vec2 pixP2() const { return m_pixP2; }
    @property vec2 texP1() const { return m_texP1; }
    @property vec2 texP2() const { return m_texP2; }

    @property vec2 pixDims() const { return m_pixDims; }
    @property vec2 texDims() const { return m_texDims; }
}
