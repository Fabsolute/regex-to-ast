defmodule RegexToAST.Char do
  import NimbleParsec

  @special_char_map %{
    ?n => ?\n,
    ?r => ?\r,
    ?t => ?\t,
    ?v => ?\v,
    ?b => ?\b,
    ?f => ?\f,
    ?e => ?\e,
    ?s => ?\s,
    ?d => ?\d
  }

  @special_char_keys Map.keys(@special_char_map)

  hex_char = ascii_char([?0..?9, ?a..?f, ?A..?F])
  octal_char = ascii_char([?0..?7])
  special_char = ascii_char(@special_char_keys)

  defcombinator :capture_hex,
                ignore(string("\\"))
                |> ignore(string("x"))
                |> choice([
                  hex_char
                  |> concat(hex_char),
                  ignore(string("{"))
                  |> concat(hex_char)
                  |> repeat(hex_char)
                  |> ignore(string("}"))
                ])
                |> reduce({List, :to_integer, [16]})

  defcombinator :capture_octal,
                ignore(string("\\"))
                |> concat(octal_char)
                |> concat(octal_char)
                |> concat(octal_char)
                |> reduce({List, :to_integer, [8]})

  defcombinator :capture_special,
                ignore(string("\\"))
                |> concat(special_char)
                |> reduce({:escape_special_char, []})

  defparsec :parse_char,
            choice([
              parsec(:capture_hex),
              parsec(:capture_octal),
              parsec(:capture_special)
            ])

  defp escape_special_char([char]), do: Map.get(@special_char_map, char)
end
