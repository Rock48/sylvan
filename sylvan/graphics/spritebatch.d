module sylvan.graphics.spritebatch;
import derelict.opengl.gl;
import derelict.opengl.glext;
import gl3n.linalg;
import sylvan.graphics.textureregion;

class SpriteBatch {
private:
    struct Vertex {
        vec2 pos;
        vec2 tex;
        vec4 col;
    }

    struct Batch {
        Vertex[] vertices;
        GLushort[] indices;
        GLuint vaoid, vboid, iboid;
        GLushort vertexCount, indexCount;
        bool valid;
    }

    Batch[GLuint] batches;

public:
    this() {}

    void begin() {
        foreach (ref Batch batch; batches) {
            if (batch.valid) {
                glDeleteBuffers(1, &batch.vboid);
                glDeleteBuffers(1, &batch.iboid);
                version(OSX) {
                    glDeleteVertexArraysAPPLE(1, &batch.vaoid);
                } else {
                    glDeleteVertexArrays(1, &batch.vaoid);
                }
            }
        }
        batches = null;
    }

    void add(TextureRegion tr, ref const vec2 p) {
        GLuint texid = tr.m_tex.m_texid;
        Vertex v;

        if (texid !in batches) {
            batches[texid] = Batch.init;
            batches[texid].valid = true;
        }

        v.pos = p;
        v.tex = tr.m_texP1;
        v.col = vec4(1.0f, 1.0f, 1.0f, 1.0f);
        batches[texid].vertices ~= v;

        v.pos = vec2(p.x + tr.m_pixDims.x, p.y);
        v.tex = vec2(tr.m_texP2.x, tr.m_texP1.y);
        v.col = vec4(1.0f, 1.0f, 1.0f, 1.0f);
        batches[texid].vertices ~= v;

        v.pos = p + tr.m_pixDims;
        v.tex = tr.m_texP2;
        v.col = vec4(1.0f, 1.0f, 1.0f, 1.0f);
        batches[texid].vertices ~= v;

        v.pos = vec2(p.x, p.y + tr.m_pixDims.y);
        v.tex = vec2(tr.m_texP1.x, tr.m_texP2.y);
        v.col = vec4(1.0f, 1.0f, 1.0f, 1.0f);
        batches[texid].vertices ~= v;

        GLushort vc = batches[texid].vertexCount;
        batches[texid].indices ~= cast(GLushort)(vc);
        batches[texid].indices ~= cast(GLushort)(vc + 2);
        batches[texid].indices ~= cast(GLushort)(vc + 3);
        batches[texid].indices ~= cast(GLushort)(vc);
        batches[texid].indices ~= cast(GLushort)(vc + 1);
        batches[texid].indices ~= cast(GLushort)(vc + 2);

        batches[texid].vertexCount += 4;
        batches[texid].indexCount += 6;
        batches[texid].valid = true;
    }

    void end() {
        foreach (ref Batch batch; batches) {
            version(OSX) {
                glGenVertexArraysAPPLE(1, &batch.vaoid);
                glBindVertexArrayAPPLE(batch.vaoid);
            } else{
                glGenVertexArrays(1, &batch.vaoid);
                glBindVertexArray(batch.vaoid);
            }

            glEnableClientState(GL_VERTEX_ARRAY);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
            glEnableClientState(GL_COLOR_ARRAY);
            glEnableClientState(GL_INDEX_ARRAY);

            glGenBuffers(1, &batch.vboid);
            glBindBuffer(GL_ARRAY_BUFFER, batch.vboid);
            glBufferData(GL_ARRAY_BUFFER, batch.vertexCount * Vertex.sizeof,
                         batch.vertices.ptr, GL_STATIC_DRAW);
            glVertexPointer(2, GL_FLOAT, Vertex.sizeof, cast(void*)(0));
            glTexCoordPointer(2, GL_FLOAT, Vertex.sizeof, cast(void*)(float.sizeof * 2));
            glColorPointer(4, GL_FLOAT, Vertex.sizeof, cast(void*)(float.sizeof * 4));

            glGenBuffers(1, &batch.iboid);
            glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, batch.iboid);
            glBufferData(GL_ELEMENT_ARRAY_BUFFER, GLushort.sizeof * batch.indexCount,
                         batch.indices.ptr, GL_STATIC_DRAW);

            version(OSX) {
                glBindVertexArrayAPPLE(0);
            } else {
                glBindVertexArray(0);
            }
        }
    }

    void clear() {
        foreach (ref Batch batch; batches) {
            if (batch.valid) {
                glDeleteBuffers(1, &batch.vboid);
                glDeleteBuffers(1, &batch.iboid);
                version(OSX) {
                    glDeleteVertexArraysAPPLE(1, &batch.vaoid);
                } else {
                    glDeleteVertexArrays(1, &batch.vaoid);
                }
            }
        }
        batches = null;
    }

    void draw() {
        foreach (GLuint texid, ref Batch batch; batches) {
            if (batch.valid) {
                version(OSX) {
                    glBindVertexArrayAPPLE(batch.vaoid);
                } else {
                    glBindVertexArray(batch.vaoid);
                }
                glBindTexture(GL_TEXTURE_2D, texid);
                glDrawElements(GL_TRIANGLES, batch.indexCount,
                               GL_UNSIGNED_SHORT, cast(void*)0);
                version(OSX) {
                    glBindVertexArrayAPPLE(0);
                } else {
                    glBindVertexArray(0);
                }
            }
        }
    }
}
