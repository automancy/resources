fn id_deps() {
  [["direction", "DIRECTION"], ["requested_from_coord", "REQUESTED_FROM_COORD"]]
}

fn function_id() {
  "master_node"
}

fn handle_transaction(input) {
  let requested_from_coord = this[REQUESTED_FROM_COORD];

  if requested_from_coord != () {
    return TransResult::PassOn(requested_from_coord, input.stack, input.source_coord, input.root_coord, input.root_id)
  }
}

fn handle_extract_request(input) {
  let direction = this[DIRECTION];

  this[REQUESTED_FROM_COORD] = input.requested_from_coord;

  if direction != () {
    return Result::MakeExtractRequest(
      input.coord + direction,
      input.id,
      input.coord,
      OnFailAction::None(),
    );
  }
}
