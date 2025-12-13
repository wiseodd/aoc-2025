app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
}

import pf.Stdout
import pf.File

main! = |_args|
    # input1 = File.read_utf8!("data/day_11_example_01.txt")?
    # input2 = File.read_utf8!("data/day_11_example_02.txt")?

    input = File.read_utf8!("data/day_11_input_01.txt")?

    children =
        input
        |> Str.trim
        |> Str.split_on("\n")
        |> List.map(
            |line|
                when line |> Str.split_on(" ") is
                    [node_str, .. as rest] ->
                        when node_str |> Str.to_utf8 is
                            [.. as node, ':'] -> (node |> Str.from_utf8 |> Result.with_default(""), rest)
                            _ -> crash "unreachable"

                    _ -> crash "unreachable",
        )
        |> Dict.from_list

    res1 = puzzle1("you", children) |> Num.to_str
    res2 = puzzle2("svr", children) |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}\nPuzzle 2: ${res2}")?

    Ok({})

puzzle1 : Str, Dict Str (List Str) -> U64
puzzle1 = |node, children|
    do_puzzle1(node, children, Dict.empty({})) |> .0

do_puzzle1 : Str, Dict Str (List Str), Dict Str U64 -> (U64, Dict Str U64)
do_puzzle1 = |node, children, memo|
    if node == "out" then
        (1, memo)
    else if memo |> Dict.contains(node) then
        (memo |> Dict.get(node) |> Result.with_default(0), memo)
    else
        when children |> Dict.get(node) is
            Err(_) -> crash "unreachable"
            Ok(next_nodes) ->
                (final_counts, final_memo) =
                    next_nodes
                    |> List.walk(
                        ([], memo),
                        |(counts, m), n|
                            (c, next_m) = do_puzzle1(n, children, m)
                            (counts |> List.append(c), next_m),
                    )
                res = final_counts |> List.sum
                (res, final_memo |> Dict.insert(node, res))

puzzle2 : Str, Dict Str (List Str) -> U64
puzzle2 = |node, children|
    do_puzzle2(node, Bool.false, Bool.false, children, Dict.empty({})) |> .0

do_puzzle2 : Str, Bool, Bool, Dict Str (List Str), Dict (Str, Bool, Bool) U64 -> (U64, Dict (Str, Bool, Bool) U64)
do_puzzle2 = |node, seen_dac, seen_fft, children, memo|
    if node == "out" then
        (Num.from_bool(seen_dac and seen_fft), memo)
    else if memo |> Dict.contains((node, seen_dac, seen_fft)) then
        (memo |> Dict.get((node, seen_dac, seen_fft)) |> Result.with_default(0), memo)
    else
        when children |> Dict.get(node) is
            Err(_) -> crash "unreachable"
            Ok(next_nodes) ->
                (final_counts, final_memo) =
                    next_nodes
                    |> List.walk(
                        ([], memo),
                        |(counts, m), n|
                            (c, next_m) = do_puzzle2(
                                n,
                                seen_dac or (node == "dac"),
                                seen_fft or (node == "fft"),
                                children,
                                m,
                            )
                            (counts |> List.append(c), next_m),
                    )

                res = final_counts |> List.sum
                (res, final_memo |> Dict.insert((node, seen_dac, seen_fft), res))
