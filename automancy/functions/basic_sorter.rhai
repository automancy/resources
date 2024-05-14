fn id_deps() {
    [
        ["item", "ITEM"],
        ["direction", "DIRECTION"],
    ]
}

fn function_id() {
    "basic_sorter"
}

fn handle_transaction(input) {
    let item = this[ITEM]?.as_item();
    let direction = this[DIRECTION];

    if item != () && direction != () {
        if input.stack.item == item {
            return [TransResult::PASS_ON, input.coord + direction];
        } else {
            return [TransResult::PASS_ON, input.coord + direction.rotate_right()];
        }
    }
}