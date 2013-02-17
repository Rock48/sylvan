module main;
import std.conv, std.datetime, std.random, std.stdio, std.c.stdlib;
import derelict.opengl.gl, derelict.opengl.glext;
import derelict.sdl.sdl;
import gl3n.linalg;

import sylvan.graphics.graphics;

int width, height;
bool running;

Random gen;

struct Ball {
    enum Color {
        Red,
        Green,
        Blue,
    }

    vec2 pos;
    vec2 vel;
    Color col;
}
immutable(float) BALL_RADIUS = 32.0f;
Ball[] balls;

void initgl() {
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0.0, cast(double)width, cast(double)height, 0.0, -1.0, 1.0);
    glViewport(0, 0, width, height);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
}

void onKey(SDLKey key) {
    if (key == SDLK_ESCAPE) {
        running = false;
    } else if (key == SDLK_SPACE) {
        vec2 pos = vec2(
                uniform(BALL_RADIUS, cast(float)width - BALL_RADIUS, gen),
                uniform(BALL_RADIUS, cast(float)height - BALL_RADIUS, gen)
        );

        vec2 vel = vec2(
                uniform(-200.0f, 200.0f, gen),
                uniform(-200.0f, 200.0f, gen)
        );

        Ball.Color col = cast(Ball.Color)uniform(0, 3, gen);
        
        balls ~= Ball(pos, vel, col);
    }
}

void collide(ref Ball b1, ref Ball b2) {
    vec2 delta = b1.pos - b2.pos;
    float dist = delta.length;

    if (dist == 0.0f) {
        delta = vec2(1.0f, 0.0f);
        dist = 1.0f;
    }

    delta *= (1.0f / dist);

    vec2 mt = delta * ((BALL_RADIUS * 2.0f) - dist);
    b1.pos += (mt * 0.5f);
    b2.pos -= (mt * 0.5f);
    
    float aci = dot(b1.vel, delta);
    float bci = dot(b2.vel, delta);
    
    b1.vel += (delta * (bci - aci));
    b2.vel += (delta * (aci - bci));
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

    DerelictGL.loadClassicVersions(GLVersion.GL21);
    DerelictGL.loadExtensions();

    initgl();

    Texture ballTex = Texture.load("ballcol.png");
    scope(exit) ballTex.free();
    vec2 dims = vec2(BALL_RADIUS, BALL_RADIUS);

    TextureRegion redBall = new TextureRegion(
            vec2(0.0f, 0.0f),
            vec2(63.0f, 63.0f),
            ballTex);

    TextureRegion greenBall = new TextureRegion(
            vec2(64.0f, 0.0f),
            vec2(127.0f, 63.0f),
            ballTex);

    TextureRegion blueBall = new TextureRegion(
            vec2(0.0f, 64.0f),
            vec2(63.0f, 127.0f),
            ballTex);

    SpriteBatch batch = new SpriteBatch();
    scope(exit) batch.clear();

    StopWatch sw;
    sw.start();
    auto last = sw.peek();
    auto secondCounter = last;
    int frameCounter = 0;

    running = true;
    while(running) {
        SDL_Event e;
        while(SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT)
                running = false;
            else if (e.type == SDL_KEYDOWN)
                onKey(e.key.keysym.sym);
        }


        sw.stop();
        auto curr = sw.peek();
        sw.start();
        float dt = (curr - last).to!("seconds", float)();
        last = curr;
        if ((curr - secondCounter).to!("seconds", float)() > 1.0f) {
            writef("%d FPS\n", frameCounter);
            frameCounter = 0;
            secondCounter = curr;
        }

        batch.begin();
        for (int i = 0; i < balls.length; i++) {
            balls[i].pos += balls[i].vel * dt;

            for (int j = i + 1; j < balls.length; j++) {
                if (distance(balls[i].pos, balls[j].pos) < (BALL_RADIUS * 2.0f))
                    collide(balls[i], balls[j]);
            }

            vec2 p1 = balls[i].pos - dims;
            vec2 p2 = balls[i].pos + dims;

            if (p1.x <= 0.0f) {
                balls[i].pos.x = BALL_RADIUS;
                balls[i].vel.x = -balls[i].vel.x;
            } else if (p2.x >= cast(float)width) {
                balls[i].pos.x = cast(float)width - BALL_RADIUS;
                balls[i].vel.x = -balls[i].vel.x;
            }

            if (p1.y <= 0.0f) {
                balls[i].pos.y = BALL_RADIUS;
                balls[i].vel.y = -balls[i].vel.y;
            } else if (p2.y >= cast(float)height) {
                balls[i].pos.y = cast(float)height - BALL_RADIUS;
                balls[i].vel.y = -balls[i].vel.y;
            }

            //if ((p1.x <= 0.0f) || (p2.x >= cast(float)width))
            //    balls[i].vel.x = -balls[i].vel.x;
            //if ((p1.y <= 0.0f) || (p2.y >= cast(float)height))
            //    balls[i].vel.y = -balls[i].vel.y;

            switch(balls[i].col) {
            case Ball.Color.Red:
                batch.add(redBall, p1);
                break;
            case Ball.Color.Green:
                batch.add(greenBall, p1);
                break;
            case Ball.Color.Blue:
                batch.add(blueBall, p1);
                break;
            default:
                stderr.writef("Got invalid ball color\n");
                break;
            }
        }
        batch.end();

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        batch.draw();

        SDL_GL_SwapBuffers();
        frameCounter += 1;
    }

    return EXIT_SUCCESS;
}

