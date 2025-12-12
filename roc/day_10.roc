app [main!] {
    pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
}

import pf.Stdout
import pf.File

Machine : {
    target : List Bool,
    actions : List List U64,
    joltages : List U64,
}

main! = |_args|
    # input = File.read_utf8!("data/day_10_example_01.txt")?
    input = File.read_utf8!("data/day_10_input_01.txt")?

    machines : List Machine
    machines =
        input
        |> Str.trim
        |> Str.split_on("\n")
        |> List.map(
            |line|
                when line |> Str.split_on(" ") is
                    [raw_target, .. as raw_actions, raw_joltages] ->
                        target =
                            when raw_target |> Str.to_utf8 is
                                ['[', .. as tgts, ']'] ->
                                    tgts |> List.map(|t| t == '#')

                                _ -> crash "unreachable"

                        actions =
                            raw_actions
                            |> List.map(
                                |a|
                                    when a |> Str.to_utf8 is
                                        ['(', .. as lights, ')'] ->
                                            lights
                                            |> Str.from_utf8
                                            |> Result.with_default("")
                                            |> Str.split_on(",")
                                            |> List.map(
                                                |v|
                                                    v |> Str.to_u64 |> Result.with_default(0),
                                            )

                                        _ -> crash "unreachable",
                            )

                        joltages =
                            when raw_joltages |> Str.to_utf8 is
                                ['{', .. as jtgs, '}'] ->
                                    jtgs
                                    |> Str.from_utf8
                                    |> Result.with_default("")
                                    |> Str.split_on(",")
                                    |> List.map(
                                        |v|
                                            v |> Str.to_u64 |> Result.with_default(0),
                                    )

                                _ -> crash "unreachable"

                        { target: target, actions: actions, joltages: joltages }

                    _ -> crash "unreachable",
        )

    res1 = machines |> puzzle1 |> Num.to_str

    Stdout.line!("Puzzle 1: ${res1}\nPuzzle 2: ")

puzzle1 : List Machine -> U64
puzzle1 = |machines|
    machines
    |> List.map(
        |machine|
            do_puzzle1(
                List.repeat(Bool.false, List.len(machine.target)),
                machine,
                Dict.empty({}),
            )
            |> .0,
    )
    |> List.sum

do_puzzle1 : List Bool, Machine, Dict (List Bool) U64 -> (U64, Dict (List Bool) U64)
do_puzzle1 = |state, machine, memo|
    if state == machine.target then
        (0, memo)
    else
        when memo |> Dict.get(state) is
            Ok(val) -> (val, memo)
            Err(_) ->
                # Set current state as "pending" to avoid cycle
                # Since applying action a then again a, will results back to
                # the same state
                pending_memo = Dict.insert(memo, state, Num.max_u64)

                (min_cost, final_memo) =
                    machine.actions
                    |> List.walk(
                        (999999999, pending_memo),
                        |(acc_cost, m), action|
                            next_state =
                                action # Toggle each indices in an action
                                |> List.walk(
                                    state,
                                    |a_state, idx|
                                        a_state |> List.update(idx, Bool.not),
                                )

                            (next_cost, next_m) = do_puzzle1(next_state, machine, m)

                            # When arriving at a pending state, prune
                            if next_cost == Num.max_u64 then
                                (acc_cost, next_m)
                            else
                                (Num.min(acc_cost, next_cost + 1), next_m),
                    )

                (min_cost, final_memo |> Dict.insert(state, min_cost))

