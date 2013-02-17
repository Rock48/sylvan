module terrain.tilemap;
import std.random, std.stdio;
import sylvan.noise.noise;
import terrain.tile;

class TileMap {
private:
    int m_width, m_height;
    Tile[] m_tiles;

public:
    this(int width, int height) {
        m_width = width;
        m_height = height;
        m_tiles = new Tile[width * height];
    }

    Tile get(int x, int y) {
        return m_tiles[y * m_width + x];
    }

    void set(int x, int y, Tile t) {
        m_tiles[y * m_width + x] = t;
    }

    void generate(uint seed = unpredictableSeed) {
        NoiseGen gen = new Perlin(seed);
        gen = new Fbm(gen, 4);
        gen = new Clamp(gen);

        double maxH = 0.50;
        for (int x = 0; x < m_width; x++) {
            double xin = cast(double)x / cast(double)m_width;
            double h = ((gen.noise(xin) + 1.0) / 2.0) * maxH;
            int tileH = cast(int)(h * cast(float)m_height);
            tileH = m_height - tileH;

            set(x, tileH, Tile.Grass);
            for (int y = tileH + 1; y < m_height; y++)
                set(x, y, Tile.Earth);
        }
    }

    @property int width() const { return m_width; }
    @property int height() const { return m_height; }
}
