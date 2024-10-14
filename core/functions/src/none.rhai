fn id_deps() {
    [
        ["tile_model", "TILE_MODEL"],
        ["$tile", "TILE_TAG"],
    ]
}

fn function_id() {
    "none"
}

fn tile_render(input) {
    let commands = [];
    let model = input.setup[TILE_MODEL];

    if (input.unloading) {
        commands += Render::Untrack(TILE_TAG, model);
    
        return commands;
    }
    
    if (input.loading) {
        commands += Render::Track(TILE_TAG, model);
    
        commands += Render::Transform(TILE_TAG, model, input.coord.as_translation());
    }

    commands
}