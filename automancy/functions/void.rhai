fn id_deps() {
  []
}

fn function_id() {
  "void"
}

fn handle_transaction(input) {
  return TransResult::Consume(ItemStack(input.stack.amount, input.stack.id), input.source_coord, input.root_coord);
}
