fn id_deps() {
  [["item", "ITEM"], ["direction", "DIRECTION"]]
}

fn function_id() {
  "basic_sorter"
}

fn handle_transaction(input) {
  let item = this[ITEM];
  let direction = this[DIRECTION];

  if item != () && direction != () {
    if input.stack.id == item {
      return TransResult::PassOn(input.coord + direction, input.stack, input.source_coord, input.root_coord, input.root_id);
    } else {
      return TransResult::PassOn(input.coord + direction.rotate_right(), input.stack, input.source_coord, input.root_coord, input.root_id);
    }
  }
}
