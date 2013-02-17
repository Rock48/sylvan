module sylvan.graphics.image;
import std.string, std.c.string;
import sylvan.graphics.color;
import sylvan.graphics.stb_image;

class Image {
package:
    int m_width, m_height;
    Color[] m_pixels;

public:
    this() {}

    this(int width, int height) {
        m_width = width;
        m_height = height;
        m_pixels = new Color[width * height];
    }

    void clear(Color c) {
        m_pixels[] = c;
    }

    void setPixel(int x, int y, Color c) {
        m_pixels[y * m_width + x] = c;
    }
    
    Color getPixel(int x, int y) {
        return m_pixels[y * m_width + x];
    }

    @property int width() const { return m_width; }
    @property int height() const { return m_height; }

    static Image load(string path) {
        int width, height, bpp;

        ubyte *pixels = stbi_load(path.toStringz(), &width, &height, &bpp, 4);
        if (pixels == null)
            throw new ImageException("Could not load image " ~ path);
        scope(exit) stbi_image_free(pixels);

        Image img = new Image(width, height);
        memcpy(img.m_pixels.ptr, pixels, width * height * 4);
        return img;
    }
}

class ImageException : Exception {
public:
    this() { super("An image exception occurred"); }
    this(string s) { super(s); }
}

