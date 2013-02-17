module sylvan.noise.noisegen;

interface NoiseGen {
    double noise(double xin);
    double noise(double xin, double yin);
}

