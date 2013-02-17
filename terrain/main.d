module main;
import std.conv, std.datetime, std.random, std.stdio, std.c.stdlib;
import derelict.sdl.sdl;
import derelict.opengl.gl;
import gl3n.linalg;

import sylvan.graphics.graphics;
import terrain.camera;
import terrain.tile;
import terrain.tilemap;

bool keys[SDLK_LAST];

bool running;
Camera cam;
TileMap tmap;

SpriteBatch batch;
Texture terrainTex;
TextureRegion[Tile] tileTex;

void initgl() {
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(0.0, cast(double)cam.screenDim.x,
            cast(double)cam.screenDim.y, 0.0,
            -1.0, 1.0);
    glViewport(0, 0, cam.screenDim.x, cam.screenDim.y);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    // glTranslatef(0.375f, 0.375f, 0.0f);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    //glClearColor(0.65f, 0.84f, 1.0f, 0.0f);
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
}

void render() {
    batch.begin();
    for (int y = 0; y < cam.screenTileDim.y; y++) {
        for (int x = 0; x < cam.screenTileDim.x; x++) {
            Tile t = tmap.get(cam.tilePos.x + x, cam.tilePos.y + y);
            if (t == Tile.Sky) continue;
            vec2 p = vec2(cast(float)x * cam.tileDim.x, cast(float)y * cam.tileDim.y);
            batch.add(tileTex[t], p);
        }
    }
    batch.end();
}

void onKey(SDLKey key) {
    switch(key) {
    case SDLK_ESCAPE:
        running = false;
        break;
    case SDLK_SPACE:
        tmap.generate();
        break;
    default:
        break;
    }

    // writef("Camera pos: (%d,%d)\n", cam.tilePos.x, cam.tilePos.y);
}

int main(string[] args) {
    if (args.length < 5) {
        writef("Usage: %s {screenWidth} {screenHeight} {mapWidth} {mapHeight}\n", args[0]);
        return EXIT_SUCCESS;
    }

    int screenWidth = parse!int(args[1]);
    int screenHeight = parse!int(args[2]);
    int mapWidth = parse!int(args[3]);
    int mapHeight = parse!int(args[4]);
    cam.screenDim.x = screenWidth;
    cam.screenDim.y = screenHeight;

    DerelictGL.load();
    DerelictSDL.load();

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        stderr.writef("Could not initialize SDL: %s\n",
                to!string(SDL_GetError()));
        return EXIT_FAILURE;
    }
    scope(exit) SDL_Quit();

    SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, 32);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

    if (SDL_SetVideoMode(screenWidth, screenHeight, 0, SDL_OPENGL) == null) {
        stderr.writef("Could not create SDL window: %s\n",
                to!string(SDL_GetError()));
        return EXIT_FAILURE;
    }

    DerelictGL.loadClassicVersions(GLVersion.GL21);
    DerelictGL.loadExtensions();
    initgl();

    terrainTex = Texture.load("terrain.png");
    scope(exit) terrainTex.free();

    tileTex[Tile.Sky] = new TextureRegion(vec2(0.0f, 0.0f), vec2(31.0f, 31.0f), terrainTex);
    tileTex[Tile.Grass] = new TextureRegion(vec2(32.0f, 0.0f), vec2(63.0f, 31.0f), terrainTex);
    tileTex[Tile.Earth] = new TextureRegion(vec2(0.0f, 32.0f), vec2(31.0f, 63.0f), terrainTex);

    cam.tilePos.x = 0;
    cam.tilePos.y = screenHeight / 2;
    cam.tileDim.x = 32.0f;
    cam.tileDim.y = 32.0f;
    cam.screenTileDim.x = screenWidth / 32;
    cam.screenTileDim.y = screenHeight / 32;

    tmap = new TileMap(mapWidth, mapHeight);
    tmap.generate();
    
    batch = new SpriteBatch();
    scope(exit) batch.clear();

    running = true;
    while(running) {
        SDL_Event e;
        while(SDL_PollEvent(&e)) {
            if (e.type == SDL_QUIT) {
                running = false;
            } else if (e.type == SDL_KEYDOWN) {
                keys[e.key.keysym.sym] = true;
                onKey(e.key.keysym.sym);
            } else if (e.type == SDL_KEYUP) {
                keys[e.key.keysym.sym] = false;
            }
        }

        if (keys[SDLK_UP]) cam.tilePos.y  = cam.tilePos.y - 1;
        if (keys[SDLK_RIGHT]) cam.tilePos.x = cam.tilePos.x + 1;
        if (keys[SDLK_DOWN]) cam.tilePos.y = cam.tilePos.y + 1;
        if (keys[SDLK_LEFT]) cam.tilePos.x = cam.tilePos.x - 1;

        if (cam.tilePos.x < 0)
            cam.tilePos.x = 0;
        else if ((cam.tilePos.x + cam.screenTileDim.x) >= tmap.width)
            cam.tilePos.x = tmap.width - cam.screenTileDim.x - 1;

        if (cam.tilePos.y < 0)
            cam.tilePos.y = 0;
        else if ((cam.tilePos.y + cam.screenTileDim.y) >= tmap.height)
            cam.tilePos.y = tmap.height - cam.screenTileDim.y - 1;
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        render();
        batch.draw();

        SDL_GL_SwapBuffers();
    }
    return EXIT_SUCCESS;
}
