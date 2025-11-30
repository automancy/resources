fn id_deps() {
    [
        ["direction", "DIRECTION"],
        ["link", "LINK"],
        ["tile_config_direction", "DIRECTION_LABEL"],
        ["tip_direction", "DIRECTION_TIP"],
    ]
}

fn script_id() {
    "node"
}

fn tile_render(input) {
    lib::automancy::tile_render::simple_tile_render(input, this[DIRECTION], DIRECTION)
}

fn handle_tick(input) {
    let link = this[LINK];

    if link != () {
        return Result::MakeExtractRequest(
            link,
            input.id,
            input.coord,
            OnFailAction::RemoveData(LINK),
        );
    }
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
    return Ui::Col([
        Ui::CenterRow([Ui::Label(DIRECTION_LABEL), Ui::InfoTip(DIRECTION_TIP)]),
        Ui::HexDirInput(DIRECTION),
    ]);
}
