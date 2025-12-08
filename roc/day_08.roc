app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
}

import pf.Stdout
import pf.File

Loc : {
    x : I64,
    y : I64,
    z : I64,
}

main! = |_args|
    input = File.read_utf8!("data/day_08_example_01.txt")?
    # input = File.read_utf8!("data/day_08_input_01.txt")?

    locs =
        input
        |> Str.trim
        |> Str.split_on("\n")
        |> List.map(
            |line|
                vals =
                    line
                    |> Str.split_on(",")
                    |> List.map(
                        |v| v |> Str.to_i64 |> Result.with_default(0),
                    )
                when vals is
                    [x, y, z] -> { x: x, y: y, z: z }
                    _ -> { x: 0, y: 0, z: 0 },
        )

    # res1 = map |> puzzle1(start, Dict.empty({})) |> .0 |> Num.to_str
    # res2 = map |> puzzle2(start, Dict.empty({})) |> .0 |> Num.to_str

    Stdout.line!("Puzzle 1: \nPuzzle 2: ")

pair_dists : List Loc -> List (Loc, Loc, I64)
pair_dists = |locs|
    locs
    |> List.map_with_index(
        |loc1, i|
            locs
            |> List.walk_from(
                i + 1,
                [],
                |acc, loc2|
                    norm1 = loc1 |> normsq
                    norm2 = loc2 |> normsq
                    acc
                    |> List.append(
                        (
                            if Num.min(norm1, norm2) == norm1 then loc1 else loc2,
                            if Num.max(norm1, norm2) == norm1 then loc1 else loc2,
                            distsq(loc1, loc2),
                        ),
                    ),
            ),
    )
    |> List.join
    |> Set.from_list # Remove dups
    |> Set.to_list
    |> List.sort_with( |a, b| 
    )

normsq : Loc -> I64
normsq = |loc|
    (loc.x |> Num.pow_int(2))
    + (loc.y |> Num.pow_int(2))
    + (loc.z |> Num.pow_int(2))

distsq : Loc, Loc -> I64
distsq = |loc1, loc2|
    loc1.x * loc2.x + loc1.y * loc2.y + loc1.z * loc2.z
