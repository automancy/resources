fn id_deps() {
  [
    ["direction", "DIRECTION"],
    ["link", "LINK"],
    ["requested_from_coord", "REQUESTED_FROM_COORD"],

    ["tile_config_direction", "DIRECTION_LABEL"],
    ["tip_direction", "DIRECTION_TIP"],
    ["tile_config_linkage", "LINKAGE_LABEL"],
    ["tip_linkage", "LINKAGE_TIP"],
    ["tile_config_link_button", "LINKAGE_BUTTON_TEXT"],
  ]
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

fn tile_config(input) {
  return Ui::Col([
    Ui::CenterRow([
      Ui::Label(LINKAGE_LABEL),
      Ui::InfoTip(LINKAGE_TIP)
    ]),
    Ui::Linkage(LINK, LINKAGE_BUTTON_TEXT),
    Ui::CenterRow([
      Ui::Label(DIRECTION_LABEL),
      Ui::InfoTip(DIRECTION_TIP)
    ]),
    Ui::HexDirInput(DIRECTION),
  ]);
}