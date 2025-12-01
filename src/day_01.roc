app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br" }

import pf.Stdout
import pf.File

main! = |_args|
    # input = File.read_utf8!("data/day_01_example_01.txt")?
    input = File.read_utf8!("data/day_01_input_01.txt")?
    lines = input |> Str.split_on("\n")
    res1 = lines |> puzzle1! |> Num.to_str
    Stdout.line!("${res1}")

puzzle1! : List Str => U64
puzzle1! = |lines|
    lines
    |> List.map(|line| split_line(line, 1))
    |> List.walk!(
        [50],
        |state, elem|
            curr = state |> List.last |> Result.with_default(50)
            state |> List.append(move(curr, elem)),
    )
    |> List.count_if(|elem| elem == 0)

move : I64, { dir : Str, steps : I64 } -> I64
move = |curr, instruction|
    res =
        when instruction.dir is
            "R" -> curr + instruction.steps
            _ -> curr - instruction.steps
    res |> modulo(100)

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
