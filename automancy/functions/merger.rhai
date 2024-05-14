fn id_deps() {
    [
        ["direction", "DIRECTION"],
    ]
}

fn function_id() {
    "merger"
}

fn handle_transaction(input) {
    let direction = this[DIRECTION];
    
    if direction != () {
        return [TransResult::PASS_ON, input.coord + direction];
    }
}