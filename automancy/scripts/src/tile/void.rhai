fn id_deps() {
    []
}

fn script_id() {
    "void"
}

fn tile_render(input) {
    lib::automancy::tile_render::simple_tile_render(input)
}

fn handle_transaction(input) {
    return TransResult::Consume(
        ItemStack(input.stack.amount, input.stack.id),
        input.source_coord,
        input.root_coord,
    );
}
