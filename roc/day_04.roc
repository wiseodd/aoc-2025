app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
    unicode: "https://github.com/roc-lang/unicode/releases/download/0.3.0/9KKFsA4CdOz0JIOL7iBSI_2jGIXQ6TsFBXgd086idpY.tar.br",
}

import pf.Stdout
import pf.File
import unicode.Grapheme

main! = |_args|
    # input = File.read_utf8!("data/day_04_example_01.txt")?
    input = File.read_utf8!("data/day_04_input_01.txt")?

    map =
        input
        |> Str.trim
        |> Str.split_on("\n")
        |> List.keep_oks(Grapheme.split)
    max_i = map |> List.len
    max_j = map |> List.get(0) |> Result.with_default([]) |> List.len

    res1 = (map |> puzzle1(max_i, max_j)).total |> Num.to_str
    res2 = map |> puzzle2(max_i, max_j, 0) |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}\nPuzzle 2: ${res2}")

puzzle1 : List List Str, U64, U64 -> { total : U64, coords : List { i : U64, j : U64 } }
puzzle1 = |map, max_i, max_j|
    map
    |> List.walk_with_index(
        { total: 0, coords: [] },
        |state, row, i|
            row
            |> List.walk_with_index(
                state,
                |state2, entry, j|
                    accessible = entry |> is_accessible(i, j, map, max_i, max_j)
                    {
                        total: state2.total + Num.from_bool(accessible),
                        coords: state2.coords |> append_if(accessible, { i: i, j: j }),
                    },
            ),
    )

puzzle2 : List List Str, U64, U64, U64 -> U64
puzzle2 = |map, max_i, max_j, acc|
    { total, coords } = map |> puzzle1(max_i, max_j)

    when coords is
        [] -> acc + total
        _ ->
            coords
            |> List.walk(
                map,
                |state, coord|
                    state |> List.update(coord.i, |row| row |> List.set(coord.j, ".")),
            )
            |> puzzle2(max_i, max_j, acc + total)

is_accessible : Str, U64, U64, List List Str, U64, U64 -> Bool
is_accessible = |entry, i, j, map, max_i, max_j|
    when entry is
        "." -> Bool.false
        _ ->
            []
            |> append_if(i > 0, map |> get(ssub(i, 1), j))
            |> append_if(j > 0, map |> get(i, ssub(j, 1)))
            |> append_if(i + 1 < max_i, map |> get(i + 1, j))
            |> append_if(j + 1 < max_j, map |> get(i, j + 1))
            |> append_if(i > 0 and j > 0, map |> get(ssub(i, 1), ssub(j, 1)))
            |> append_if(i > 0 and j + 1 < max_j, map |> get(ssub(i, 1), j + 1))
            |> append_if(i + 1 < max_i and j > 0, map |> get(i + 1, ssub(j, 1)))
            |> append_if(i + 1 < max_i and j + 1 < max_j, map |> get(i + 1, j + 1))
            |> List.count_if(|x| x == "@")
            |> Num.is_lt(4)

get : List List Str, U64, U64 -> Str
get = |map, i, j|
    when map |> List.get(i) is
        Ok(row) ->
            when row |> List.get(j) is
                Ok(val) -> val
                Err(_) -> "."

        Err(_) -> "."

append_if : List a, Bool, a -> List a
append_if = |lst, cond, x|
    if cond then lst |> List.append(x) else lst

# Alias for Num.sub_saturated
ssub = |a, b|
    a |> Num.sub_saturated(b)
