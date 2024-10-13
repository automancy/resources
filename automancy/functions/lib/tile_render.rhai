fn id_deps() {
    [
        ["tile_model", "TILE_MODEL"],
        ["$tile", "TILE_TAG"],
        ["$direction", "DIRECTION_TAG"],
        ["core:missing", "MISSING_MODEL"],
    ]
}

fn make_matrix(coord, direction) {
    let loc = coord.as_translation();
    let dir = Matrix::IDENTITY;

    if (direction != ()) {
        dir = direction.as_rotation_z();
    }

    loc * dir 
}

fn simple_tile_render(input, direction, direction_id) {
    let commands = [];

    if (input.unloading) {
        commands += Render::Untrack(TILE_TAG, input.setup[TILE_MODEL]);
        //commands += Render::Untrack(Instance(DIRECTION_TAG, input.setup[TILE_MODEL]);

        return commands;
    }

    if (input.loading) {
        commands += Render::Track(TILE_TAG, input.setup[TILE_MODEL]);
        //commands += Render::Track(Instance(DIRECTION_TAG, input.setup[TILE_MODEL]);
        
        let m = make_matrix(input.coord, direction);

        commands += Render::Transform(TILE_TAG, input.setup[TILE_MODEL], m);
    }


    if (
        direction_id != () && input.field_changes.contains(direction_id)
    ) {
        let m = make_matrix(input.coord, direction);

        commands += Render::Transform(TILE_TAG, input.setup[TILE_MODEL], m);
    }

    return commands;
}

fn simple_tile_render(input) {
    simple_tile_render(input, (), ())
}