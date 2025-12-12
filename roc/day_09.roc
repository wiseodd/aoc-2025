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
    res2 = locs |> puzzle2 |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}\nPuzzle 2: ${res2}")

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

puzzle2 : List Loc -> I64
puzzle2 = |reds|
    greens =
        when reds is
            [first, ..] -> get_segments(reds |> List.append(first))
            _ -> crash "unreachable"

    reds
    |> List.walk_with_index(
        0,
        |state1, loc1, i|
            reds
            |> List.drop_first(i + 1)
            |> List.walk(
                state1,
                |state2, loc2|
                    size = area(loc1, loc2)

                    if size > state2 then
                        rlocs = sort_segment(loc1, loc2)
                        intersect =
                            greens
                            |> List.walk_until(
                                Bool.true,
                                |_, segment|
                                    glocs = sort_segment(segment.0, segment.1)

                                    if
                                        (
                                            glocs.0.x
                                            < rlocs.1.x
                                            and glocs.0.y
                                            < rlocs.1.y
                                            and glocs.1.x
                                            > rlocs.0.x
                                            and glocs.1.y
                                            > rlocs.0.y
                                        )
                                    then
                                        Break(Bool.false)
                                    else
                                        Continue(Bool.true),
                            )
                        if intersect then size else state2
                    else
                        state2,
            ),
    )

area : Loc, Loc -> I64
area = |corner1, corner2|
    (1 + Num.abs(corner1.x - corner2.x)) * (1 + Num.abs(corner1.y - corner2.y))

get_segments : List Loc -> List (Loc, Loc)
get_segments = |locs|
    when locs is
        [] | [_] -> []
        [loc1, loc2, .. as rest] ->
            get_segments(rest |> List.prepend(loc2)) |> List.prepend((loc1, loc2))

sort_segment : Loc, Loc -> (Loc, Loc)
sort_segment = |loc1, loc2|
    x1 = Num.min(loc1.x, loc2.x)
    x2 = Num.max(loc1.x, loc2.x)
    y1 = Num.min(loc1.y, loc2.y)
    y2 = Num.max(loc1.y, loc2.y)
    ({ x: x1, y: y1 }, { x: x2, y: y2 })

