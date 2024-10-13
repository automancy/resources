fn id_deps() {
    []
}

fn function_id() {
    "splitter_right"
}

fn tile_render(input) {
    lib::automancy::tile_render::simple_tile_render(input);
}

fn handle_transaction(input) {
    return lib::automancy::splitter::simple_split(
        input,
        [TileCoord::TOP_LEFT, TileCoord::BOTTOM_LEFT, TileCoord::RIGHT],
    );
}
