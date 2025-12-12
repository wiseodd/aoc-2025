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
puzzle2 = |locs|
    boundary = locs |> get_boundary

    locs
    |> List.walk_with_index(
        0,
        |state1, loc1, i|
            locs
            |> List.drop_first(i + 1)
            |> List.walk(
                state1,
                |state2, loc2|
                    loc12 = { x: loc1.x, y: loc2.y }
                    loc21 = { x: loc2.x, y: loc1.y }

                    if !(Set.contains(boundary, loc12) or is_inside(loc12, locs)) then
                        state2
                    else if !(Set.contains(boundary, loc21) or is_inside(loc21, locs)) then
                        state2
                    else
                        rect_edges =
                            get_boundary([loc1, loc12, loc2, loc21])
                            |> Set.remove(loc1)
                            |> Set.remove(loc2)
                            |> Set.remove(loc12)
                            |> Set.remove(loc21)
                        edges_valid =
                            rect_edges
                            |> Set.to_list
                            |> List.all(
                                |point|
                                    Set.contains(boundary, point) or is_inside(point, locs),
                            )

                        if edges_valid then
                            Num.max(state2, area(loc1, loc2))
                        else
                            state2,
            ),
    )

area : Loc, Loc -> I64
area = |corner1, corner2|
    (1 + Num.abs(corner1.x - corner2.x)) * (1 + Num.abs(corner1.y - corner2.y))

get_boundary : List Loc -> Set Loc
get_boundary = |locs|
    when locs is
        [first, ..] ->
            do_get_boundary(locs |> List.append(first))
            |> Set.from_list

        _ -> crash "unreachable"

do_get_boundary : List Loc -> List Loc
do_get_boundary = |locs|
    when locs is
        [] | [_] -> locs
        [loc1, loc2, .. as rest] ->
            line = if loc1.x == loc2.x then
                List.range({ start: At(loc1.y), end: At(loc2.y) })
                |> List.map(|y| { x: loc1.x, y: y })
            else
                List.range({ start: At(loc1.x), end: At(loc2.x) })
                |> List.map(|x| { x: x, y: loc1.y })

            line
            |> List.concat(
                do_get_boundary(rest |> List.prepend(loc2)),
            )

is_inside : Loc, List Loc -> Bool
is_inside = |loc, locs|
    when locs is
        [first, ..] ->
            count_crossings(loc, locs |> List.append(first)) |> Num.is_odd

        _ -> crash "unreachable"

count_crossings : Loc, List Loc -> U64
count_crossings = |loc, locs|
    when locs is
        [] | [_] -> 0
        [v1, v2, .. as rest] ->
            crossing = if v1.x == v2.x then
                min_y = Num.min(v1.y, v2.y)
                max_y = Num.max(v1.y, v2.y)

                if v1.x >= loc.x and loc.y > min_y and loc.y <= max_y then
                    1
                else
                    0
            else
                0

            crossing + count_crossings(loc, rest |> List.prepend(v2))

