app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
}

import pf.Stdout
import pf.File

main! = |_args|
    # input = File.read_utf8!("data/day_06_example_01.txt")?
    input = File.read_utf8!("data/day_06_input_01.txt")?

    { before, after } =
        input
        |> Str.trim
        |> Str.split_last("\n")?

    ops = after |> split_and_clean
    nums =
        before
        |> Str.split_on("\n")
        |> List.map(|line| line |> split_and_clean)

    res1 = puzzle1(nums, ops) |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}\nPuzzle 2: ")

puzzle1 : List List Str, List Str -> U64
puzzle1 = |nums, ops|
    n_nums = nums |> List.len
    n_probs = ops |> List.len
    nums_flat = nums |> List.join

    List.range({ start: At(0), end: Before(n_probs) })
    |> List.walk(
        0,
        |acc1, prob_idx|
            op_str = ops |> get_op(prob_idx)
            op = if op_str == "+" then Num.add else Num.mul
            init = if op_str == "+" then 0 else 1

            acc1
            + (
                List.range({ start: At(0), end: Before(n_nums) })
                |> List.walk(
                    init,
                    |acc2, num_idx|
                        acc2 |> op(nums_flat |> get_num(n_probs * num_idx + prob_idx)),
                )
            ),
    )

split_and_clean : Str -> List Str
split_and_clean = |str|
    str |> Str.split_on(" ") |> List.map(Str.trim) |> List.drop_if(Str.is_empty)

get_num : List Str, U64 -> U64
get_num = |lst, idx|
    lst |> List.get(idx) |> Result.with_default("0") |> Str.to_u64 |> Result.with_default(0)

get_op : List Str, U64 -> Str
get_op = |lst, idx|
    lst |> List.get(idx) |> Result.with_default("+")

