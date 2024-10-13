fn id_deps() {
    []
}

fn function_id() {
    "splitter_left"
}

fn tile_render(input) {
    lib::automancy::tile_render::simple_tile_render(input);
}

fn handle_transaction(input) {
    return lib::automancy::splitter::simple_split(
        input,
        [TileCoord::TOP_RIGHT, TileCoord::BOTTOM_RIGHT, TileCoord::LEFT],
    );
}
