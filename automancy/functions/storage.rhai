fn id_deps() {
  [
    ["buffer", "BUFFER"],
    ["item", "ITEM"],
    ["item_type", "ITEM_TYPE"],
    ["capacity", "CAPACITY"],

    ["tile_config_inventory", "INVENTORY_LABEL"],
    ["tip_inventory", "INVENTORY_TIP"],
    ["tile_config_empty_inventory", "EMPTY_INVENTORY_LABEL"],
    
    ["tile_config_item_type", "ITEM_TYPE_LABEL"],
    ["tile_config_capacity", "CAPACITY_LABEL"],

    ["tip_search_item", "SEARCH_ITEM_TIP"],
  ]
}

fn function_id() {
  "storage"
}

fn handle_transaction(input) {
  let item = this[ITEM];
  let capacity = this[CAPACITY];

  if capacity != () && item != () && input.stack.id == item {
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

    return TransResult::Consume(ItemStack(inserting, input.stack.id), input.source_coord, input.root_coord);
  }
}

fn handle_transaction_result(input) {
  let buffer = this[BUFFER];

  buffer.take(input.transferred.id, input.transferred.amount);

  this[BUFFER] = buffer;
}

fn handle_extract_request(input) {
  let item = this[ITEM];
  let buffer = this[BUFFER];

  if item != () && buffer != () {
    let stored = buffer[item];

    if stored > 0 {
      return Result::MakeTransaction(
        input.requested_from_coord,
        input.id,
        input.coord,
        [ItemStack(item, stored)],
      );
    }
  }
}

fn tile_config(input) {
  return Ui::Col([
    Ui::CenterRow([
      Ui::Label(INVENTORY_LABEL),
      Ui::InfoTip(INVENTORY_TIP)
    ]),
    Ui::Inventory(BUFFER, EMPTY_INVENTORY_LABEL),
    Ui::Row([
      Ui::Label(CAPACITY_LABEL),
      Ui::InputAmount(CAPACITY, 65536)
    ]),
    Ui::Label(ITEM_TYPE_LABEL),
    Ui::SelectableIds(ITEM, SEARCH_ITEM_TIP, item_ids_of_tag(input.setup[ITEM_TYPE])),
  ]);
}
