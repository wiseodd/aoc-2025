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
    # input = File.read_utf8!("data/day_08_example_01.txt")?
    # n = 10

    input = File.read_utf8!("data/day_08_input_01.txt")?
    n = 1000

    locs : List Loc
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

    res1 = locs |> puzzle1(n) |> Num.to_str
    # res2 = map |> puzzle2(start, Dict.empty({})) |> .0 |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}\nPuzzle 2: ")

puzzle1 : List Loc, U64 -> U64
puzzle1 = |locs, n|
    # Disjoint-set union
    init_parents = locs 
        |> List.map(|loc| (loc, loc)) 
        |> Dict.from_list
    parents = locs 
        |> pair_dists 
        |> List.take_first(n)
        |> List.walk(
            init_parents,
            |state, pair|
                p1 = find_set(pair.0, state)
                p2 = find_set(pair.1, state)
                if p1 != p2 then
                    Dict.insert(state, p2, p1)
                else
                    state
        )
    locs 
        |> List.walk(
            Dict.empty({}),
            |state, loc|
                set = find_set(loc, parents)
                when state |> Dict.get(set) is
                    Ok(count) -> state |> Dict.insert(set, count + 1)
                    Err(_) -> state |> Dict.insert(set, 1)
        )
        |> Dict.to_list
        |> List.map(.1)
        |> List.sort_desc
        |> List.take_first(3)
        |> List.product

find_set : Loc, Dict Loc Loc -> Loc
find_set = |loc, parents|
    when parents |> Dict.get(loc) is
        Ok(parent) -> 
            # Recursively find the largest superset
            if parent == loc then
                loc
            else
                find_set(parent, parents)
        Err(_) -> loc

pair_dists : List Loc -> List (Loc, Loc, I64)
pair_dists = |locs|
    locs
    |> List.map_with_index(
        |loc1, i|
            locs
            |> List.drop_first(i + 1)
            |> List.map(|loc2| (loc1, loc2, distsq(loc1, loc2))),
    )
    |> List.join
    |> Set.from_list # Remove dups
    |> Set.to_list
    |> List.sort_with(
        |a, b|
            Num.compare(a.2, b.2), 
    )

normsq : Loc -> I64
normsq = |loc|
    (loc.x |> Num.pow_int(2))
    + (loc.y |> Num.pow_int(2))
    + (loc.z |> Num.pow_int(2))

distsq : Loc, Loc -> I64
distsq = |loc1, loc2|
    (Num.pow_int(loc1.x - loc2.x, 2) 
    + Num.pow_int(loc1.y - loc2.y, 2) 
    + Num.pow_int(loc1.z - loc2.z, 2))
