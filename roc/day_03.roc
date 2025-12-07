app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
    unicode: "https://github.com/roc-lang/unicode/releases/download/0.3.0/9KKFsA4CdOz0JIOL7iBSI_2jGIXQ6TsFBXgd086idpY.tar.br",
}

import pf.Stdout
import pf.File
import unicode.Grapheme

main! = |_args|
    # input = File.read_utf8!("data/day_03_example_01.txt")?
    input = File.read_utf8!("data/day_03_input_01.txt")?

    entries =
        input
        |> Str.trim
        |> Str.split_on("\n")
        |> List.keep_oks(Grapheme.split)

    res1 = entries |> List.map(puzzle1) |> List.sum |> Num.to_str
    res2 = entries |> List.map(puzzle2) |> List.sum |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}\nPuzzle 2: ${res2}")

# Brute force O(N^2)
puzzle1 : List Str -> U64
puzzle1 = |bank|
    len = bank |> List.len
    List.range({ start: At(0), end: Before(len) })
    |> List.walk(
        0,
        |max, i|
            first = List.get(bank, i) |> Result.with_default("0")

            res =
                List.range({ start: After(i), end: Before(len) })
                |> List.walk(
                    max,
                    |state, j|
                        second = List.get(bank, j) |> Result.with_default("0")
                        num = "${first}${second}" |> Str.to_u64 |> Result.with_default(0)
                        Num.max(num, state),
                )

            Num.max(res, max),
    )

# Greedy policy in O(12*N). Brute force is O(N^12) here.
puzzle2 : List Str -> U64
puzzle2 = |bank|
    do_puzzle2(bank, "") |> Str.to_u64 |> Result.with_default(0)

do_puzzle2 : List Str, Str -> Str
do_puzzle2 = |bank, acc|
    acc_len = acc |> Str.count_utf8_bytes
    if acc_len == 12 then
        acc
    else
        { max, argmax } =
            bank
            |> List.drop_last(12 - acc_len - 1)
            |> List.keep_oks(Str.to_u64)
            |> max_argmax

        do_puzzle2(
            bank
            |> List.drop_first(argmax + 1),
            "${acc}${max |> Num.to_str}",
        )

max_argmax : List (Num a) -> { max : Num a, argmax : U64 }
max_argmax = |lst|
    lst
    |> List.walk_with_index(
        { max: 0, argmax: 0 },
        |state, x, i|
            if x > state.max then
                { max: x, argmax: i }
            else
                state,
    )
