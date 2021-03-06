module engine.render.particlesystem;
import engine;
import std.algorithm.sorting;
import std.exception;
import engine.config;

/**
    Max number of particles
*/
enum MAX_PARTICLES = 10_000u;

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
        Scale of the particle
    */
    float scale = 1;

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
private GLint vsize;
private Camera2D baseCamera;

package(engine) void initParticleSystem() {

    // Initialize all the base needs for rendering particles
    glGenVertexArrays(1, &vao);
    particleShader = new Shader(import("shaders/particle.vert"), import("shaders/particle.frag"));
    baseCamera = new Camera2D();
    vp = particleShader.getUniformLocation("vp");
    vsize = particleShader.getUniformLocation("size");
}

/**
    A particle system
*/
class ParticleSystem {
private:
    struct RParticle {
        vec2 position;
        vec4 color;
        float scale;
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
        alias comparer = (a, b) => cmp(a.lifespan, b.lifespan) > 0;
        sort!comparer(particles[0..MAX_PARTICLES]);
        
        // Recalculate how many alive particles we have
        aliveParticles = 0;
        foreach(i; 0..MAX_PARTICLES) {
            if (particles[i].lifespan <= 0 || !isFinite(particles[i].lifespan)) break;
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
        Size (in pixels) to render at
    */
    int size = 0;

    /**
        Constructor
    */
    this(Texture texture, void delegate(ref Particle) particleInitFunc, void delegate(ref Particle) particleActorFunc) {
        this.texture = texture;
        this.particleInitFunc = particleInitFunc;
        this.particleActorFunc = particleActorFunc;

        enforce(texture.width == texture.height, "Textures are not equally sized on both axies");
        this.textureSize = texture.width;
        this.size = textureSize;

        // We pre-generate the VBO and its data
        // so that we can update smaller sections later
        glBindVertexArray(vao);
        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(
            GL_ARRAY_BUFFER, 
            RParticle.sizeof*MAX_PARTICLES, 
            particleRenderData.ptr,
            GL_DYNAMIC_DRAW
        );

        foreach(i; 0..MAX_PARTICLES) particles[i].lifespan = 0;
    }

    /**
        Gets how many particles are alive
    */
    size_t alive() {
        return aliveParticles;
    }

    /**
        Updates the particle system

        NOTE: Run this in fixed time step
    */
    void update() {
        foreach(i; 0..aliveParticles) {

            // Lifespan needs to decrease and the 
            // particle needs to follow its set direction
            particles[i].lifespan -= KM_TIMESTEP;
            particles[i].position += particles[i].direction;

            // User logic
            particleActorFunc(particles[i]);

            // Update the data for the rendering copies.
            particleRenderData[i].position = particles[i].position;
            particleRenderData[i].color = particles[i].color;
            particleRenderData[i].scale = particles[i].scale;
        }

        // We want to clean up any unused particles
        // and refill the buffer
        // Otherwise we wouldn't see anything
        // on the screen
        cleanup();
        updateBuffer();
    }

    /**
        Draw the particle system
    */
    void draw(Shader shader = null, Camera2D camera = null) {
        if (aliveParticles == 0) return;

        if (shader is null) shader = particleShader;
        if (camera is null) camera = baseCamera;

        // Disable depth testing so that we don't
        // experience weirdness with particles
        // cutting off other textures
        glDisable(GL_DEPTH_TEST);
        glEnable(GL_POINT_SPRITE);
        glEnable(GL_VERTEX_PROGRAM_POINT_SIZE);

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
            cast(void*)(RParticle.color.offsetof)
        );

        glEnableVertexAttribArray(2);
        glVertexAttribPointer(
            2,
            1,
            GL_FLOAT,
            GL_FALSE,
            RParticle.sizeof,
            cast(void*)(RParticle.scale.offsetof)
        );

        // Use shader and bind texture
        shader.use();
        shader.setUniform(vp, camera.matrix);
        shader.setUniform(vsize, cast(float)size);

        texture.bind();

        // Draw the particles
        glDrawArrays(GL_POINTS, 0, cast(int)aliveParticles);

        // Set up for other draw calls after
        glDisableVertexAttribArray(0);
        glDisableVertexAttribArray(1);
        glDisable(GL_VERTEX_PROGRAM_POINT_SIZE);
        glDisable(GL_POINT_SPRITE);
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
            p.scale = 1;

            particleInitFunc(p);

            particles[aliveParticles+i] = p;

            // Update particle render info
            particleRenderData[aliveParticles+i].position = p.position;
            particleRenderData[aliveParticles+i].color = p.color;
            particleRenderData[aliveParticles+i].scale = p.scale;
        }

        aliveParticles++;
        cleanup();
        updateBuffer();
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