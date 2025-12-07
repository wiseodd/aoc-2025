app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
}

import pf.Stdout
import pf.File

main! = |_args|
    # input = File.read_utf8!("data/day_05_example_01.txt")?
    input = File.read_utf8!("data/day_05_input_01.txt")?

    { before, after } =
        input
        |> Str.trim
        |> Str.split_first("\n\n")?

    ids = after |> Str.split_on("\n") |> List.keep_oks(Str.to_u64)
    ranges =
        before
        |> Str.split_on("\n")
        |> List.map(
            |line|
                when line |> Str.split_on("-") is
                    [a, b] ->
                        {
                            start: a |> Str.to_u64 |> Result.with_default(0),
                            end: b |> Str.to_u64 |> Result.with_default(0),
                        }

                    _ -> { start: 0, end: 0 },
        )

    res1 = puzzle1(ids, ranges, 0) |> Num.to_str
    res2 = puzzle2(ranges) |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}\nPuzzle 2: ${res2}")

puzzle1 : List U64, List { start : U64, end : U64 }, U64 -> U64
puzzle1 = |ids, ranges, total|
    when ids is
        [] -> total
        [val, .. as rest] ->
            contained =
                ranges
                |> List.any(
                    |range|
                        range.start <= val and val <= range.end,
                )
            if contained then
                puzzle1(rest, ranges, total + 1)
            else
                puzzle1(rest, ranges, total)

puzzle2 : List { start : U64, end : U64 } -> U64
puzzle2 = |ranges|
    ranges
    |> List.sort_with(
        |range1, range2|
            Num.compare(range1.start, range2.start),
    )
    |> merge_ranges([])
    |> List.map(|range| range.end - range.start + 1)
    |> List.sum

merge_ranges : List { start : U64, end : U64 }, List { start : U64, end : U64 } -> List { start : U64, end : U64 }
merge_ranges = |ranges, acc|
    when ranges is
        [] -> acc
        [range] -> acc |> List.append(range)
        [first, second, .. as rest] ->
            # Overlapping
            if first.end >= second.start then
                merged = { start: first.start, end: Num.max(first.end, second.end) }
                merge_ranges(rest |> List.prepend(merged), acc)
            else
                merge_ranges(rest |> List.prepend(second), acc |> List.append(first))

