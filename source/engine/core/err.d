module engine.core.err;
import engine;
import engine.ver;
import std.array;
import std.format;

class FatalException : Exception
{
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @safe
    {
        super("FATAL ERROR\n"~msg, file, line, nextInChain);
    }
}

private {
    dstring[] messages;
    vec2[] offsets;
    float renderHeight;
}

void kmSetException(Exception ex) {

    // We want to render at a pretty big resolution
    GameFont.setSize(20);

    string[] mesgs = ex.msg.split('\n');
    renderHeight = GameFont.getMetrics().y*messages.length;

    foreach(i, msg; mesgs) {
        messages ~= kmToEngineString(msg);
        vec2 measure = GameFont.measure(messages[$-1]);
        offsets ~= vec2(-measure.x/2, i == 0 ? -10 : GameFont.getMetrics().y*i);
    }
}

void kmRenderException() {
    vec2 origin = vec2(kmCameraViewWidth()/2, (kmCameraViewHeight()/2)-(GameFont.getMetrics().y*3/2));
    foreach(i, msg; messages) {
        GameFont.draw(msg, origin+offsets[i]);
    }
    GameFont.draw("v. %s"d.format(KM_VERSION), vec2(8, 8));
    GameFont.flush();
}