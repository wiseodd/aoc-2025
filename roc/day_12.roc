app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
}

import pf.Stdout
import pf.File

main! = |_args|
    # input = File.read_utf8!("data/day_12_example_01.txt")?
    input = File.read_utf8!("data/day_12_input_01.txt")?

    regions =
        when input |> Str.trim |> Str.split_on("\n\n") is
            [.., regs] ->
                regs |> Str.split_on("\n")

            _ -> crash "unreachable"

    res1 = puzzle1(regions) |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}")?

    Ok({})

puzzle1 : List Str -> U64
puzzle1 = |regions|
    regions
    |> List.map(
        |region|
            when region |> Str.split_on(": ") is
                [wh, cts] ->
                    (w, h) =
                        when wh |> Str.split_on("x") |> List.keep_oks(Str.to_u64) |> List.take_first(2) is
                            [a, b] -> (a, b)
                            _ -> crash "unreachable"

                    counts = cts |> Str.split_on(" ") |> List.keep_oks(Str.to_u64)

                    if (w // 3) * (h // 3) >= List.sum(counts) then 1 else 0

                _ -> crash "unreachable",
    )
    |> List.sum
