fn id_deps() {
    [
        ["buffer", "BUFFER"],
        ["script", "SCRIPT"],
        ["direction", "DIRECTION"],
    ]
}

fn function_id() {
    "machine"
}

fn handle_tick(input) {
    let direction = this[DIRECTION];

    if direction == () {
        return;
    }

    let coord = input.coord + direction;

    let script = this[SCRIPT]?.as_script();
    if script == () {
        return;
    }

    let outputs = script.instructions.outputs;
    let inputs = script.instructions.inputs;

    if inputs == () {
        return [Result::MAKE_TRANSACTION, coord, input.id, input.coord, outputs];
    }

    let buffer = this[BUFFER];
    if buffer == () {
        return;
    }

    for input in inputs {
        let stored = buffer[input.item];

        if stored < input.amount {
            return;
        }
    }

    [Result::MAKE_TRANSACTION, coord, input.id, input.coord, outputs]
}

fn handle_transaction(input) {
    let inputs = this[SCRIPT]?.as_script()?.instructions?.inputs;
    if inputs == () {
        return;
    }

    let matched = item_matches(input.stack.item.id, inputs);
    if matched == () {
        return;
    }

    let buffer = this.get_or_new_inventory(BUFFER);
    
    let amount = matched.amount * 8;
    let stored = buffer[input.stack.item];
    if stored >= amount {
        return;
    }
    let inserting = min(input.stack.amount, amount - stored);

    buffer[input.stack.item] = stored + inserting;

    this[BUFFER] = buffer;

    return [TransResult::CONSUME, inserting]
}

fn handle_transaction_result(input) {
    let inputs = this[SCRIPT]?.as_script()?.instructions?.inputs;
    let buffer = this[BUFFER];

    if inputs != () && buffer != () {
        for input in inputs {
            let stored = buffer[input.item];

            if stored < input.amount {
                stored = 0;
                throw "in transaction result: tile does not have enough input for the supposed output!";
            } else {
                buffer[input.item] = stored - input.amount;
            }
        }

        this[BUFFER] = buffer;
    }
}

fn tile_config(input) {
    let ui = [];

    return ui;
}