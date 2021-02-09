module engine.render.particlesystem;
import engine;
import std.algorithm.sorting;
import std.exception;

/**
    Max number of particles
*/
enum MAX_PARTICLES = 5_000u;

/**
    A singular particle
*/
struct Particle {
    /**
        Position of the particle
    */
    vec2 position;

    /**
        Direction the particle is moving
    */
    vec2 direction;

    /**
        The color of the particle
    */
    vec4 color;

    /**
        The lifespan of the particle
    */
    float lifespan;
}

private GLuint vao;
private Shader particleShader;

private GLint vp;
private Camera2D baseCamera;

package(engine) void initParticleSystem() {
    glGenVertexArrays(1, &vao);
    particleShader = new Shader(import("shaders/particle.vert"), import("shaders/particle.frag"));
    baseCamera = new Camera2D();
    vp = particleShader.getUniformLocation("vp");
}

/**
    A particle system
*/
class ParticleSystem {
private:
    struct RParticle {
        vec2 position;
        vec4 color;
    }

    GLuint vbo;
    Shader shader;

    // Texture
    Texture texture;

    // List of particles
    Particle [MAX_PARTICLES] particles;
    RParticle[MAX_PARTICLES] particleRenderData;
    size_t aliveParticles;

    int textureSize;

    // Function that will run for every particle
    void delegate(ref Particle) particleActorFunc;

    // Function that will run for every particle instantiation
    void delegate(ref Particle) particleInitFunc;

    void cleanup() {
        // If everything's dead we don't need to try to sort it.
        if (aliveParticles == 0) return;

        // Sort in descending order
        // So that we have to sort less when particles die
        sort!("a.lifespan > b.lifespan")(particles[0..MAX_PARTICLES]);
        
        // Recalculate how many alive particles we have
        aliveParticles = 0;
        foreach(i; 0..MAX_PARTICLES) {
            if (i <= 0) break;
            aliveParticles++;
        }
    }

    void updateBuffer() {
        glBindVertexArray(vao);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferSubData(
            GL_ARRAY_BUFFER, 
            0, 
            RParticle.sizeof*aliveParticles, 
            particleRenderData.ptr
        );
    }

public:
    ~this() {

    }

    /**
        The start life time of particles in seconds
    */
    float startLifetime = 1;

    /**
        Constructor
    */
    this(Texture texture, void delegate(ref Particle) particleInitFunc, void delegate(ref Particle) particleActorFunc) {
        this.texture = texture;
        this.particleInitFunc = particleInitFunc;
        this.particleActorFunc = particleActorFunc;

        enforce(texture.width == texture.height, "Textures are not equally sized on both axies");
        this.textureSize = texture.width;

        glBindVertexArray(vao);
        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(
            GL_ARRAY_BUFFER, 
            RParticle.sizeof*MAX_PARTICLES, 
            particleRenderData.ptr,
            GL_DYNAMIC_DRAW
        );
    }

    /**
        Updates the particle system

        NOTE: Run this in fixed time step
    */
    void update() {
        foreach(i; 0..aliveParticles) {
            particles[i].lifespan -= 0.016;
            particleActorFunc(particles[i]);
            particleRenderData[i].position = particles[i].position;
            particleRenderData[i].color = particles[i].color;
        }
        cleanup();

        updateBuffer();
    }

    /**
        Draw the particle system
    */
    void draw(int size = 0, Shader shader = null, Camera2D camera = null) {
        if (aliveParticles == 0) return;

        if (shader is null) shader = particleShader;
        if (camera is null) camera = baseCamera;

        if (size <= 0) size = this.textureSize;

        // Disable depth testing so that we don't
        // experience weirdness with particles
        // cutting off other textures
        glDisable(GL_DEPTH_TEST);

        // Bind buffers and vao
        glBindVertexArray(vao);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);

        // Set up vertex array attributes
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(
            0,
            2,
            GL_FLOAT,
            GL_FALSE,
            RParticle.sizeof,
            null
        );

        glEnableVertexAttribArray(1);
        glVertexAttribPointer(
            1,
            4,
            GL_FLOAT,
            GL_FALSE,
            RParticle.sizeof,
            cast(void*)(float.sizeof*2)
        );

        // Use shader and bind texture
        shader.use();
        shader.setUniform(vp, camera.matrix);

        texture.bind();

        // Draw the particles
        glPointSize(size);
        glDrawArrays(GL_POINTS, 0, cast(int)aliveParticles);

        // Set up for other draw calls after
        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(1);
        glEnable(GL_DEPTH_TEST);
    }

    /**
        Spawns `count` particles at `position`
    */
    void spawn(vec2 position, size_t count = 1) {
        foreach(i; 0..count) {

            // Handle the particle list getting exhausted of space
            if (aliveParticles+i >= MAX_PARTICLES) {
                count = i;
                break;
            }

            Particle p;
            p.position = position;
            p.lifespan = startLifetime;

            particleInitFunc(p);

            particles[aliveParticles+i] = p;

            // Update particle render info
            particleRenderData[aliveParticles+i].position = p.position;
            particleRenderData[aliveParticles+i].color = p.color;
        }
        aliveParticles += count;

        this.updateBuffer();
    }

    /**
        Kills all the particles in the system
    */
    void killAllParticles() {
        foreach(i; 0..MAX_PARTICLES) {
            particles[i].lifespan = 0;
        }
        aliveParticles = 0;
    }
}