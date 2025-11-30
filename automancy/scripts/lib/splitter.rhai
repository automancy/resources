fn id_deps() {
    []
}

fn simple_split(input, dirs) {
    let direction = input.source_coord - input.coord;

    let choices;
    if direction == dirs[0] {
        choices = [dirs[1], dirs[2]]
    } else if direction == dirs[1] {
        choices = [dirs[0], dirs[2]]
    } else if direction == dirs[2] {
        choices = [dirs[0], dirs[1]]
    } else {
        return;
    }

    let direction = if input.random % 2 == 0 {
        choices[0]
    } else {
        choices[1]
    };

    return TransResult::PassOn(
        input.coord + direction,
        input.stack,
        input.source_coord,
        input.root_coord,
        input.root_id,
    );
}
