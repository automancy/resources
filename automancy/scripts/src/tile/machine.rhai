fn id_deps() {
    [
        ["buffer", "BUFFER"],
        ["recipe", "RECIPE"],
        ["recipes", "RECIPES"],
        ["direction", "DIRECTION"],
        ["tile_config_direction", "DIRECTION_LABEL"],
        ["tip_direction", "DIRECTION_TIP"],
        ["tile_config_recipe", "RECIPE_LABEL"],
        ["tip_recipe", "RECIPE_TIP"],
        ["tile_config_inventory", "INVENTORY_LABEL"],
        ["tip_inventory", "INVENTORY_TIP"],
        ["tile_config_empty_inventory", "EMPTY_INVENTORY_LABEL"],
        ["tip_search_recipe", "SEARCH_RECIPE_TIP"],
    ]
}

fn script_id() {
    "machine"
}

fn tile_render(input) {
    lib::automancy::tile_render::simple_tile_render(input, this[DIRECTION], DIRECTION)
}

fn handle_tick(input) {
    let direction = this[DIRECTION];

    if direction == () {
        return;
    }
    let coord = input.coord + direction;

    let recipe = this[RECIPE]?.as_recipe();
    if recipe == () {
        return;
    }

    let outputs = recipe.instructions.outputs;
    let inputs = recipe.instructions.inputs;

    if inputs == () {
        return Result::MakeTransaction(coord, input.id, input.coord, outputs);
    }

    let buffer = this[BUFFER];
    if buffer == () {
        return;
    }

    for input in inputs {
        let stored = buffer[input.id];

        if stored < input.amount {
        return;
        }
    }

    return Result::MakeTransaction(coord, input.id, input.coord, outputs);
}

fn handle_transaction(input) {
    let inputs = this[RECIPE]?.as_recipe()?.instructions?.inputs;
    if inputs == () {
        return;
    }
    let matched = item_stack_matches(input.stack.id, inputs);
    if matched == () {
        return;
    }
    let buffer = this.get_or_new_inventory(BUFFER);

    let amount = matched.amount * 8;
    let stored = buffer[input.stack.id];
    if stored >= amount {
        return;
    }
    let inserting = min(input.stack.amount, amount - stored);

    buffer[input.stack.id] = stored + inserting;

    this[BUFFER] = buffer;

    return TransResult::Consume(
        ItemStack(inserting, input.stack.id),
        input.source_coord,
        input.root_coord,
    );
}

fn handle_transaction_result(input) {
    let inputs = this[RECIPE]?.as_recipe()?.instructions?.inputs;
    let buffer = this[BUFFER];

    if inputs != () && buffer != () {
        for input in inputs {
            let stored = buffer[input.id];

            if stored < input.amount {
                stored = 0;
                throw "in transaction result: tile does not have enough input for the supposed output!";
            } else {
                buffer[input.id] = stored - input.amount;
            }
        }

        this[BUFFER] = buffer;
    }
}

fn tile_config(input) {
    return Ui::Col([
        Ui::CenterRow([Ui::Label(INVENTORY_LABEL), Ui::InfoTip(INVENTORY_TIP)]),
        Ui::Inventory(BUFFER, EMPTY_INVENTORY_LABEL),
        Ui::CenterRow([Ui::Label(RECIPE_LABEL), Ui::InfoTip(RECIPE_TIP)]),
        Ui::SelectableRecipes(RECIPE, SEARCH_RECIPE_TIP, input.setup[RECIPES]),
        Ui::CenterRow([Ui::Label(DIRECTION_LABEL), Ui::InfoTip(DIRECTION_TIP)]),
        Ui::HexDirInput(DIRECTION),
    ]);
}
