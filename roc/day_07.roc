app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
    unicode: "https://github.com/roc-lang/unicode/releases/download/0.3.0/9KKFsA4CdOz0JIOL7iBSI_2jGIXQ6TsFBXgd086idpY.tar.br",
}

import pf.Stdout
import pf.File
import unicode.Grapheme

main! = |_args|
    # input = File.read_utf8!("data/day_07_example_01.txt")?
    input = File.read_utf8!("data/day_07_input_01.txt")?

    map : Dict (U64, U64) Str
    map =
        input
        |> Str.trim
        |> Str.split_on("\n")
        |> List.map_with_index(
            |row, i|
                row
                |> Grapheme.split
                |> Result.with_default([])
                |> List.map_with_index(
                    |val, j|
                        ((i, j), val),
                ),
        )
        |> List.join
        |> Dict.from_list

    start : (U64, U64)
    start =
        map
        |> Dict.keep_if(|((_i, _j), v)| v == "S")
        |> Dict.to_list
        |> List.first
        |> Result.map_ok(|((i, j), _v)| (i, j))
        |> Result.with_default (0, 0)

    res1 = map |> puzzle1(start, Dict.empty({})) |> .0 |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}\nPuzzle 2: ")

puzzle1 : Dict (U64, U64) Str, (U64, U64), Dict (U64, U64) U64 -> (U64, Dict (U64, U64) U64)
puzzle1 = |map, start, memo|
    next = (start.0 + 1, start.1)
    when map |> Dict.get(next) is
        Err(_) -> (0, memo) # Out of bounds, don't count
        Ok(v) ->
            when memo |> Dict.get(next) is
                Ok(_) -> (0, memo) # Already visited, don't count
                Err(_) ->
                    when v is
                        "." -> puzzle1(map, next, memo) # No split, just move forward
                        _ ->
                            # Count split on the left
                            (count_left, memo_left) = puzzle1(
                                map,
                                (start.0 + 1, start.1 - 1),
                                memo,
                            )

                            # Count split on the right
                            (count_right, memo_right) = puzzle1(
                                map,
                                (start.0 + 1, start.1 + 1),
                                memo_left,
                            )

                            all_count = 1 + count_left + count_right

                            (
                                all_count,
                                memo_right |> Dict.insert(next, all_count),
                            )
