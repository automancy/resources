fn id_deps() {
    [
        ["direction", "DIRECTION"]
    ]
}

fn function_id() {
    "merger"
}

fn render_listening_to_fields() {
    [
        DIRECTION
    ]
}

fn tile_render(input) {
    lib::automancy::tile_render::simple_tile_render(input, this[DIRECTION], DIRECTION);
}

fn handle_transaction(input) {
    let direction = this[DIRECTION];

    if direction != () {
        return TransResult::PassOn(
            input.coord + direction,
            input.stack,
            input.source_coord,
            input.root_coord,
            input.root_id,
        );
    }
}

fn tile_config(input) {
    return Ui::Col([Ui::HexDirInput(DIRECTION)]);
}
