fn id_deps() {
  [["direction", "DIRECTION"], ["link", "LINK"]]
}

fn function_id() {
  "node"
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
    return TransResult::PassOn(input.coord + direction, input.stack, input.source_coord, input.root_coord, input.root_id);
  }
}
