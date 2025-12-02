app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
    # ascii: "https://github.com/Hasnep/roc-ascii/releases/download/v0.3.1/1PCTQ0tzSijxfhxDg1k_yPtfOXiAk3j283b8EWGusVc.tar.br",
    unicode: "https://github.com/roc-lang/unicode/releases/download/0.3.0/9KKFsA4CdOz0JIOL7iBSI_2jGIXQ6TsFBXgd086idpY.tar.br",
}

import pf.Stdout
import pf.File
import unicode.Grapheme

main! = |_args|
    # input = File.read_utf8!("data/day_02_example_01.txt")?
    input = File.read_utf8!("data/day_02_input_01.txt")?

    entries =
        input
        |> Str.trim
        |> Str.split_on(",")
        |> List.map(
            |x|
                x |> Str.split_on("-"),
        )

    res1 = entries |> puzzle1 |> Num.to_str

    _ = Stdout.line!("Puzzle 1: ${res1}")
    # Stdout.line!("Puzzle 2: ${res2}")

    Ok({})

puzzle1 : List List Str -> U64
puzzle1 = |entries|
    entries
    |> List.walk(
        0,
        |state, entry|
            state + total_repeat(entry |> get(0), entry |> get(1), 0),
    )

total_repeat : Str, Str, U64 -> U64
total_repeat = |start, end, total|
    if to_int(start) > to_int(end) then
        total
    else if start |> is_repeat then
        total_repeat(Num.to_str(to_int(start) + 1), end, total + to_int(start))
    else
        total_repeat(Num.to_str(to_int(start) + 1), end, total)

is_repeat : Str -> Bool
is_repeat = |s|
    lst = Grapheme.split(s) |> Result.with_default([])
    len = lst |> List.len
    if len % 2 != 0 then
        Bool.false
    else
        { before, others } = lst |> List.split_at(len // 2)
        before == others

get : List Str, U64 -> Str
get = |lst, idx|
    lst |> List.get(idx) |> Result.with_default("")

to_int : Str -> U64
to_int = |x|
    x |> Str.to_u64 |> Result.with_default(0)
