module game.entity.player;
import game.entity;
import engine;

/**
    Player entity is special and will have some hardcoded things built in
*/
class Player : Entity {
    this(vec2i position) {
        super("Player", null, position, true);
    }
}
