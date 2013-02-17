module sylvan.noise.perlin;
import std.random;
import sylvan.noise.noisegen;

class Perlin : NoiseGen {
private:
    int[512] m_perm;

public:
    this(uint seed = unpredictableSeed) {
        auto gen = Random(seed);

        for (int i = 0; i < 256; i++)
            m_perm[i] = i;
        
        for (int i = 0; i < 256; i++) {
            int j = uniform(0, 256, gen);

            int a = m_perm[i];
            int b = m_perm[j];

            m_perm[i] = m_perm[i + 256] = b;
            m_perm[j] = m_perm[j + 256] = a;
        }
    }

    override double noise(double xin) {
        int xi = fastFloor(xin);
        double xo = xin - cast(double)xi;
        double xf = fade(xo);
        xi &= 255;

        int g0 = m_perm[xi];
        int g1 = m_perm[xi + 1];

        double n0 = dot(g0, xo);
        double n1 = dot(g1, xo - 1.0);
        
        return lerp(xf, n0, n1);
    }

    override double noise(double xin, double yin) {
        int xi = fastFloor(xin);
        int yi = fastFloor(yin);
        double xo = xin - cast(double)xi;
        double yo = yin - cast(double)yi;
        double xf = fade(xo);
        double yf = fade(yo);
        xi &= 255;
        yi &= 255;

        int g00 = m_perm[xi + m_perm[yi]];
        int g10 = m_perm[xi + 1 + m_perm[yi]];
        int g01 = m_perm[xi + m_perm[yi + 1]];
        int g11 = m_perm[xi + 1 + m_perm[yi + 1]];

        double n00 = dot(g00, xo, yo);
        double n10 = dot(g10, xo - 1.0, yo);
        double n01 = dot(g01, xo, yo - 1.0);
        double n11 = dot(g11, xo - 1.0, yo - 1.0);

        return lerp(yf, lerp(xf, n00, n10), lerp(xf, n01, n11));
    }
}

private immutable(double[3][16]) grad = [
    [ 1.0, 1.0, 0.0 ], [ -1.0, 1.0, 0.0 ], [ 1.0, -1.0, 0.0 ], [ -1.0, -1.0, 0.0 ],
    [ 1.0, 0.0, 1.0 ], [ -1.0, 0.0, 1.0 ], [ 1.0, 0.0, -1.0 ], [ -1.0, 0.0, -1.0 ],
    [ 0.0, 1.0, 1.0 ], [ 0.0, -1.0, 1.0 ], [ 0.0, 1.0, -1.0 ], [ 0.0, -1.0, -1.0 ],
    [ 1.0, 1.0, 0.0 ], [ -1.0, 1.0, 0.0 ], [ 0.0, -1.0, 1.0 ], [ 0.0, -1.0, -1.0 ],
];

private int fastFloor(double x) {
    return (x > 0.0) ? cast(int)x : cast(int)x - 1;
}

private double fade(double t) {
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

private double lerp(double t, double a, double b) {
    return a + t * (b - a);
}

private double dot(int hash, double x) {
    hash &= 15;
    return grad[hash][0]*x;
}

private double dot(int hash, double x, double y) {
    hash &= 15;
    return grad[hash][0]*x + grad[hash][1]*y;
}

