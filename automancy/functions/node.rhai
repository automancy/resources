fn id_deps() {
    [
        ["direction", "DIRECTION"],
        ["link", "LINK"],
    ]
}

fn function_id() {
    "node"
}

fn handle_tick(input) {
    let link = this[LINK];

    if link != () {
        return [Result::MAKE_EXTRACT_REQUEST, link, input.id, input.coord];
    }
}

fn handle_transaction(input) {
    let direction = this[DIRECTION];

    if direction != () {
        return [TransResult::PASS_ON, input.coord + direction];
    }
}