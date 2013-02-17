module sylvan.graphics.color;

union Color {
    struct { ubyte r, g, b, a; };
    uint rgba;
}

private ubyte blendChannel(ubyte c0, ubyte c1, double alpha) {
    double c0r = cast(double)c0 / 255.0;
    double c1r = cast(double)c1 / 255.0;
    return cast(ubyte)(((c1r * alpha) + (c0r + (1.0 - alpha))) * 255.0);
}

public Color blendColor(Color c0, Color c1, double alpha) {
    return Color(blendChannel(c0.r, c1.r, alpha),
            blendChannel(c0.g, c1.g, alpha),
            blendChannel(c0.b, c1.b, alpha),
            blendChannel(c0.a, c1.a, alpha));
}

