fn id_deps() {
    [
        ["buffer", "BUFFER"],
        ["item", "ITEM"],
        ["capacity", "CAPACITY"],
        ["tile_config_capacity", "CAPACITY_LABEL"],
    ]
}

fn function_id() {
    "storage"
}

fn handle_transaction(input) {
    let item = this[ITEM]?.as_item();
    let capacity = this[CAPACITY];

    if capacity != () && item != () && input.stack.item == item {
        let buffer = this.get_or_new_inventory(BUFFER);

        let stored = buffer[item];
        if stored > capacity {
            stored = capacity;
        }

        if stored == capacity {
            return;
        }

        let inserting = min(input.stack.amount, capacity - stored);
        stored += inserting;

        buffer[item] = stored;
        this[BUFFER] = buffer;

        return [TransResult::CONSUME, inserting];
    }
}

fn handle_transaction_result(input) {
    let buffer = this[BUFFER];

    buffer.take(input.transferred.item, input.transferred.amount);
    
    this[BUFFER] = buffer;
}

fn handle_extract_request(input) {
    let item = this[ITEM]?.as_item();
    let buffer = this[BUFFER];

    if item != () && buffer != () {
        let stored = buffer[item];

        if stored > 0 {
            return [
                Result::MAKE_TRANSACTION,
                input.requested_from_coord,
                input.id,
                input.coord,
                [ItemStack(item, stored)]
            ];
        }
    }
}

fn tile_config(input) {
    let ui = [];

    ui.push([Ui::Row, [
        [Ui::Label, CAPACITY_LABEL],
        [Ui::LabelAmount, this[CAPACITY]],
    ]]);
    ui.push([Ui::SliderAmount, CAPACITY, 65536]);

    return ui;
}