fn id_deps() {
    [
        ["tile_model", "TILE_MODEL"],
        ["base_model", "BASE_MODEL"],
        ["$tile", "TILE_TAG"],
        ["$tile_base", "TILE_BASE_TAG"],
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

    let base_model = input.setup[BASE_MODEL];

    let tile_model = input.setup[TILE_MODEL];
    if (tile_model == ()) {
        tile_model = MISSING_MODEL;
    }

    if (input.unloading) {
        if (base_model != ()) {
            commands += Render::Untrack(TILE_BASE_TAG, base_model);
        }
        commands += Render::Untrack(TILE_TAG, tile_model);

        return commands;
    }

    if (input.loading) {
        if (base_model != ()) {
            commands += Render::Track(TILE_BASE_TAG, base_model);
        }
        commands += Render::Track(TILE_TAG, tile_model);
        
        let m = make_matrix(input.coord, direction);
        if (base_model != ()) {
            commands += Render::Transform(TILE_BASE_TAG, base_model, m);
        }
        commands += Render::Transform(TILE_TAG, tile_model, m);
    }


    if (
        direction_id != () && input.field_changes.contains(direction_id)
    ) {
        let m = make_matrix(input.coord, direction);
        if (base_model != ()) {
            commands += Render::Transform(TILE_BASE_TAG, base_model, m);
        }
        commands += Render::Transform(TILE_TAG, tile_model, m);
    }

    return commands;
}

fn simple_tile_render(input) {
    simple_tile_render(input, (), ())
}