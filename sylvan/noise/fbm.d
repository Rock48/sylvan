module sylvan.noise.fbm;
import sylvan.noise.noisegen;

class Fbm : NoiseGen {
private:
    NoiseGen m_source;
    int m_octaves;
    double m_frequency;
    double m_lacunarity;
    double m_persistence;

public:
    this(NoiseGen source, int octaves = 6, double frequency = 1.0,
         double lacunarity = 2.0, double persistence = 0.8) {
        m_source = source;
        m_octaves = octaves;
        m_frequency = frequency;
        m_lacunarity = lacunarity;
        m_persistence = persistence;
    }

    override double noise(double xin) {
        double freq = m_frequency;
        double amp = 1.0;
        double result = 0.0;

        for (int i = 0; i < m_octaves; i++) {
            result += m_source.noise(xin * freq) * amp;
            freq *= m_lacunarity;
            amp *= m_persistence;
        }

        return result;
    }

    override double noise(double xin, double yin) {
        double freq = m_frequency;
        double amp = 1.0;
        double result = 0.0;

        for (int i = 0; i < m_octaves; i++) {
            result += m_source.noise(xin * freq, yin * freq) * amp;
            freq *= m_lacunarity;
            amp *= m_persistence;
        }

        return result;
    }
}
