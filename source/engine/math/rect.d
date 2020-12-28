module engine.math.rect;
import engine;
import gl3n.util : is_vector;
import std.traits : isNumeric;

/**
    A rectangle
*/
struct RectImpl(T) if (isNumeric!T) {
    union {
        struct {
            /**
                X coordinate of the rectangle
            */
            T x;

            /**
                Y coordinate of the rectangle
            */
            T y;

            /**
                Width of the rectangle
            */
            T width;

            /**
                Height of the rectangle
            */
            T height;
        }

        /**
            The rectangle as a 4 dimensional vector
        */
        Vector!(T, 4) asVec;
    }

    /**
        Left side of the rectangle
    */
    T left() { return x; }

    /**
        Right side of the rectangle
    */
    T right() { return x+width; }

    /**
        Top of the tectangle
    */
    T top() { return y; }

    /**
        Bottom of the rectangle
    */
    T bottom() { return y+height; }

    /**
        Gets the center of the rectangle
    */
    Vector!(T, 2) center() { return Vector!(T, 2)(x+(width/2), y+(height/2)); }

    /**
        Gets whether a 2D vector intersects with this rectangle
    */
    bool intersects(T)(T other) if(is_vector!T && T.dimensons == 2) {
        return !(
            other.x >= this.right || 
            other.x < this.left || 
            other.y >= this.bottom || 
            other.y < this.top
        );
    }

    /**
        Gets whether this rectangle intersects with an other rectangle
    */
    bool intersects(RectImpl!T other) {
        return !(
            other.left >= this.right || 
            other.right <= this.left || 
            other.top >= this.bottom || 
            other.bottom <= this.top
        );
    }

    /**
        Returns a rectangle displaced by the specified units
    */
    RectImpl!T displace(T x, T y) {
        return RectImpl!T(this.x+x, this.y+y, this.width, this.height);
    }

    /**
        Returns a rectangle expanded in all directions by the specified units
    */
    RectImpl!T expand(T x, T y) {
        return RectImpl!T(this.x-x, this.y-y, this.width+(x*2), this.height+(y*2));
    }
}

alias Rect = RectImpl!int;
alias Rectf = RectImpl!float;
