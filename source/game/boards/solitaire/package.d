/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module game.boards.solitaire;
import game.boards.solitaire.field;
import game.boards;
import engine;
import game;
import std.random;



/**
    Solitaire Board
*/
class SolitaireBoard : GameBoard {
private:
    Field playingField;

    BoardCam camera;
    Camera2D ui;

    vec2i lastSelected = vec2i(int.min, int.min);
    vec2i selected = vec2i(int.min, int.min);

    void updateGameplay() {
        vec2i clicked = playingField.getClicked(camera.camera, Mouse.position, vec2(GameWindow.width, GameWindow.height));
        if (clicked.x != int.min) {
            
            // Clicking on the same tile twice counts as resetting the selection
            if (clicked == selected) {
                this.resetSelection();
                return;
            }

            // Can't select unplayable tiles
            if (!playingField.isPlayable(clicked)) return;


            lastSelected = selected;
            selected = clicked;
            playingField[selected].transform.scale = vec3(0.9, 0.9, 0.9);

            if (selected.x != int.min && lastSelected.x != int.min) {

                // Handle tiles that don't match
                if (playingField[selected].type != playingField[lastSelected].type) {

                    // Reset their scale
                    this.resetSelection();
                    return;
                }

                // Destroy both tiles, they are the same
                playingField.remove(selected);
                playingField.remove(lastSelected);
                selected = vec2i(int.min, int.min);
                lastSelected = vec2i(int.min, int.min);
            }
        }
    }

    void resetSelection() {

        if (selected.x != int.min) {
            playingField[selected].transform.scale = vec3(1, 1, 1);
            selected = vec2i(int.min, int.min);
        }

        if (lastSelected.x != int.min) {
            playingField[lastSelected].transform.scale = vec3(1, 1, 1);
            lastSelected = vec2i(int.min, int.min);
        }
    }

public:
    this() {
        playingField = new Field();

        ui = new Camera2D();
        camera = new BoardCam();
    }

override:

    void update() {
        camera.update();

        if (Mouse.isButtonClicked(MouseButton.Left)) {
            updateGameplay();
        }

        if (Mouse.isButtonClicked(MouseButton.Right)) {
            this.resetSelection();
            playingField.shuffle();
        }
    }

    void draw() {
        playingField.draw(camera.camera);
    }
}