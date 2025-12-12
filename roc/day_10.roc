app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
}

import pf.Stdout
import pf.File

Loc : {
    x : I64,
    y : I64,
}

main! = |_args|
    # input = File.read_utf8!("data/day_09_example_01.txt")?
    input = File.read_utf8!("data/day_09_input_01.txt")?

    locs : List Loc
    locs =
        input
        |> Str.trim
        |> Str.split_on("\n")
        |> List.map(
            |line|
                when line |> Str.split_on(",") |> List.map(|v| v |> Str.to_i64) is
                    [Ok(x), Ok(y)] -> { x: x, y: y }
                    _ -> { x: 0, y: 0 },
        )

    res1 = locs |> puzzle1 |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}\nPuzzle 2: ")

## O(N^2) algo
puzzle1 : List Loc -> I64
puzzle1 = |locs|
    locs
    |> List.walk_with_index(
        0,
        |state1, loc1, i|
            locs
            |> List.drop_first(i + 1)
            |> List.walk(state1, |state2, loc2| Num.max(state2, area(loc1, loc2))),
    )

area : Loc, Loc -> I64
area = |corner1, corner2|
    (1 + Num.abs(corner1.x - corner2.x)) * (1 + Num.abs(corner1.y - corner2.y))
