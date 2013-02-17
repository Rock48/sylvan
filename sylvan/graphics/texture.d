module sylvan.graphics.texture;
import std.string, std.c.stdlib;
import derelict.opengl.gl;
import sylvan.graphics.image;
import sylvan.graphics.stb_image;

class Texture {
package:
    float m_width, m_height;
    GLuint m_texid;
    bool m_valid;

public:
    this() {}

    this(Image img) {
        m_width = cast(float)img.width;
        m_height = cast(float)img.height;
        
        glGenTextures(1, &m_texid);
        glBindTexture(GL_TEXTURE_2D, m_texid);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, img.m_width, img.m_height,
                     0, GL_RGBA, GL_UNSIGNED_BYTE, img.m_pixels.ptr);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        m_valid = true;
    }

    void free() {
        if (m_valid) {
            glDeleteTextures(1, &m_texid);
            m_valid = false;
        } else {
            throw new TextureException("Tried to free an invalid texture");
        }
    }

    void bind() {
        if (m_valid) {
            glBindTexture(GL_TEXTURE_2D, m_texid);
        } else {
            throw new TextureException("Tried to bind an invalid texture");
        }
    }

    @property float width() const { return m_width; }
    @property float height() const { return m_height; }

    static Texture load(string path) {
        int width, height, bpp;

        ubyte *pixels = stbi_load(path.toStringz(), &width, &height, &bpp, 4);
        if (pixels == null)
            throw new TextureException("Could not load texture " ~ path);
        scope(exit) stbi_image_free(pixels);

        Texture tex = new Texture();
        tex.m_width = cast(float)width;
        tex.m_height = cast(float)height;

        glGenTextures(1, &tex.m_texid);
        glBindTexture(GL_TEXTURE_2D, tex.m_texid);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height,
                     0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        tex.m_valid = true;
        return tex;
    }
}

class TextureException : Exception {
public:
    this() { super("A texture exception occurred"); }
    this(string s) { super(s); }
}

