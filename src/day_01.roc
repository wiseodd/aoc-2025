app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br" }

import pf.Stdout
import pf.File

main! = |_args|
    # input = File.read_utf8!("data/day_01_example_01.txt")?
    input = File.read_utf8!("data/day_01_input_01.txt")?
    lines = input |> Str.split_on("\n")

    res1 = lines |> puzzle1 |> Num.to_str
    res2 = lines |> puzzle2 |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}\nPuzzle 2: ${res2}")

puzzle1 : List Str -> I64
puzzle1 = |lines|
    res =
        lines
        |> List.map(|line| line |> split_line(1))
        |> List.walk(
            { curr: 50, count: 0 },
            |state, instruction|
                next = state.curr |> move(instruction) |> modulo(100)
                { curr: next, count: state.count + Num.from_bool(next == 0) },
        )
    res.count

puzzle2 : List Str -> I64
puzzle2 = |lines|
    res =
        lines
        |> List.map(|line| split_line(line, 1))
        |> List.walk(
            { curr: 50, count: 0 },
            |state, x|
                inc = (
                    if x.dir == "R" then
                        (state.curr + x.steps) // 100
                    else if x.dir == "L" then
                        if state.curr == 0 then
                            x.steps // 100
                        else if x.steps >= state.curr then
                            1 + (x.steps - state.curr) // 100
                        else
                            0
                    else
                        0
                )

                {
                    curr: state.curr |> move(x),
                    count: state.count + inc,
                },
        )

    res.count

move : I64, { dir : Str, steps : I64 } -> I64
move = |curr, instruction|
    (
        when instruction.dir is
            "R" -> curr + instruction.steps
            _ -> curr - instruction.steps
    )
    |> modulo(100)

split_line : Str, U64 -> { dir : Str, steps : I64 }
split_line = |line, idx|
    res = line |> Str.to_utf8 |> List.split_at(idx)

    {
        dir: res.before
        |> Str.from_utf8()
        |> Result.with_default(""),
        steps: res.others
        |> Str.from_utf8()
        |> Result.with_default("")
        |> Str.to_i64
        |> Result.with_default(0),
    }

# Roc uses truncated division for modulo, so e.g. `-10 % 100 = -10`.
modulo : I64, I64 -> I64
modulo = |a, b|
    ((a % b) + b) % b

