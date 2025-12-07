app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
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
        |> List.map(|x| x |> Str.split_on("-"))

    res1 = entries |> puzzle(total_repeat) |> Num.to_str
    _ = Stdout.line!("Puzzle 1: ${res1}")

    res2 = entries |> puzzle(total_invalid) |> Num.to_str
    _ = Stdout.line!("Puzzle 2: ${res2}")

    Ok({})

puzzle : List List Str, (Str, Str, U64 -> U64) -> U64
puzzle = |entries, counter|
    entries
    |> List.walk(
        0,
        |state, entry|
            state + counter(entry |> get(0), entry |> get(1), 0),
    )

total_repeat : Str, Str, U64 -> U64
total_repeat = |start, end, total|
    if to_int(start) > to_int(end) then
        total
    else if start |> is_repeat then
        total_repeat(Num.to_str(to_int(start) + 1), end, total + to_int(start))
    else
        total_repeat(Num.to_str(to_int(start) + 1), end, total)

total_invalid : Str, Str, U64 -> U64
total_invalid = |start, end, total|
    if to_int(start) > to_int(end) then
        total
    else if start |> is_invalid then
        total_invalid(Num.to_str(to_int(start) + 1), end, total + to_int(start))
    else
        total_invalid(Num.to_str(to_int(start) + 1), end, total)

is_repeat : Str -> Bool
is_repeat = |s|
    lst = Grapheme.split(s) |> Result.with_default([])
    len = lst |> List.len
    if len % 2 != 0 then
        Bool.false
    else
        { before, others } = lst |> List.split_at(len // 2)
        before == others

is_invalid : Str -> Bool
is_invalid = |s|
    lst = Grapheme.split(s) |> Result.with_default([])
    len = lst |> List.len

    List.range({ start: At(1), end: At(len // 2) })
    |> List.keep_if(|k| k > 0 and len % k == 0)
    |> List.any(
        |k|
            chunks = lst |> List.chunks_of(k)
            List.len(chunks) >= 2 and chunks |> all_same,
    )

get : List Str, U64 -> Str
get = |lst, idx|
    lst |> List.get(idx) |> Result.with_default("")

to_int : Str -> U64
to_int = |x|
    x |> Str.to_u64 |> Result.with_default(0)

all_same : List List Str -> Bool
all_same = |lst|
    when lst is
        [] -> Bool.true
        [first, ..] -> lst |> List.all(|x| x == first)
