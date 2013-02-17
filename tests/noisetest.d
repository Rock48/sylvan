module main;
import std.conv, std.datetime, std.stdio, std.c.stdlib;
import derelict.sdl.sdl;
import derelict.opengl.gl;
import sylvan.graphics.graphics;
import sylvan.noise.noise;

int width, height;
bool running;
Texture tex;

void initgl() {
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0.0, cast(double)width, cast(double)height, 0.0, -1.0, 1.0);
    glViewport(0, 0, width, height);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glEnable(GL_TEXTURE_2D);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
}

void onKey(SDLKey key) {
    switch(key) {
    case SDLK_ESCAPE:
        running = false;
        break;
    case SDLK_SPACE:
        tex.free();
        tex = genTex();
        break;
    default:
        break;
    }
}

Texture genTex() {
    StopWatch sw;
    sw.start();
    NoiseGen gen = new Perlin();
    gen = new Fbm(gen);
    gen = new Clamp(gen);

    Image img = new Image(width, height);

    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            double xin = cast(double)x / cast(double)width;
            double yin = cast(double)y / cast(double)height;
            double h = (gen.noise(xin, yin) + 1.0) / 2.0;
            ubyte c = cast(ubyte)(h * 255.0);
            img.setPixel(x, y, Color(c, c, c, 255));
        }
    }

    sw.stop();
    writef("Time: %dms\n", sw.peek().msecs);
    return new Texture(img);
}

int main(string[] args) {
    if (args.length < 3) {
        writef("Usage: %s {width} {height}\n", args[0]);
        return EXIT_SUCCESS;
    }

    width = parse!int(args[1]);
    height = parse!int(args[2]);

    DerelictSDL.load();
    DerelictGL.load();

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        stderr.writef("Could not initialize SDL: %s\n",
                to!string(SDL_GetError()));
        return EXIT_FAILURE;
    }
    scope(exit) SDL_Quit();

    SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, 32);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

    if (SDL_SetVideoMode(width, height, 0, SDL_OPENGL) == null) {
        stderr.writef("Could not create SDL window: %s\n",
                to!string(SDL_GetError()));
        return EXIT_FAILURE;
    }
    initgl();
    
    tex = genTex();
    scope(exit) tex.free();

    running = true;
    while(running) {
        SDL_Event e;
        while(SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT)
                running = false;
            else if (e.type == SDL_KEYDOWN)
                onKey(e.key.keysym.sym);
        }

        float x1 = cast(float)width;
        float y1 = cast(float)height;

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        tex.bind();
        glBegin(GL_QUADS);

        glTexCoord2f(0.0f, 0.0f); glVertex2f(0.0f, 0.0f);
        glTexCoord2f(1.0f, 0.0f); glVertex2f(x1  , 0.0f);
        glTexCoord2f(1.0f, 1.0f); glVertex2f(x1  , y1  );
        glTexCoord2f(0.0f, 1.0f); glVertex2f(0.0f, y1  );

        glEnd();
        
        SDL_GL_SwapBuffers();
    }

    return EXIT_SUCCESS;
}

