fn id_deps() {
    [
        ["item", "ITEM"],
        ["direction", "DIRECTION"],
        ["item_type", "ITEM_TYPE"],
        ["tile_config_item_type", "ITEM_TYPE_LABEL"],
        ["tip_search_item", "SEARCH_ITEM_TIP"],
    ]
}

fn function_id() {
    "basic_sorter"
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
    let item = this[ITEM];
    let direction = this[DIRECTION];

    if item != () && direction != () {
        if input.stack.id == item {
            return TransResult::PassOn(
                input.coord + direction,
                input.stack,
                input.source_coord,
                input.root_coord,
                input.root_id,
            );
        } else {
            return TransResult::PassOn(
                input.coord + direction.rotate_right(),
                input.stack,
                input.source_coord,
                input.root_coord,
                input.root_id,
            );
        }
    }
}

fn tile_config(input) {
    return Ui::Col([
        Ui::Label(ITEM_TYPE_LABEL),
        Ui::SelectableItems(
            ITEM,
            SEARCH_ITEM_TIP,
            item_ids_of_tag(input.setup[ITEM_TYPE])
        ),
        Ui::HexDirInput(DIRECTION),
    ]);
}
