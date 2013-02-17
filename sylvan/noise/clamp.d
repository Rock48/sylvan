module sylvan.noise.clamp;
import sylvan.noise.noisegen;

class Clamp : NoiseGen {
private:
    NoiseGen m_source;
    double m_min;
    double m_max;

public:
    this(NoiseGen source, double min = -1.0, double max = 1.0) {
        m_source = source;
        m_min = min;
        m_max = max;
    }

    override double noise(double xin) {
        double result = m_source.noise(xin);

        if (result < m_min)
            return m_min;
        else if (result > m_max)
            return m_max;

        return result;
    }

    override double noise(double xin, double yin) {
        double result = m_source.noise(xin, yin);

        if (result < m_min)
            return m_min;
        else if (result > m_max)
            return m_max;

        return result;
    }
}

