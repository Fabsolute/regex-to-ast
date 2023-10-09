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

  hex_char = ascii_char([?0..?9, ?a..?f, ?A..?F])
  octal_char = ascii_char([?0..?7])

  defcombinatorp :capture_hex,
                 ignore(ascii_char([?\\]))
                 |> ignore(ascii_char([?x]))
                 |> choice([
                   hex_char
                   |> concat(hex_char),
                   ignore(ascii_char([?{]))
                   |> times(hex_char, min: 1, max: 4)
                   |> ignore(ascii_char([?}]))
                 ])
                 |> reduce({List, :to_integer, [16]})

  defcombinatorp :capture_octal,
                 ignore(ascii_char([?\\]))
                 |> concat(octal_char)
                 |> concat(octal_char)
                 |> concat(octal_char)
                 |> reduce({List, :to_integer, [8]})

  defcombinatorp :capture_special,
                 ignore(ascii_char([?\\]))
                 |> utf8_char([])
                 |> reduce(:escape_special_char)

  defcombinatorp :capture_char,
                 choice([
                   parsec(:capture_hex),
                   parsec(:capture_octal),
                   parsec(:capture_special),
                   utf8_char(
                     not: ?^,
                     not: ?.,
                     not: ?[,
                     not: ?$,
                     not: ?(,
                     not: ?),
                     not: ?|,
                     not: ?*,
                     not: ?+,
                     not: ??,
                     not: ?\\,
                     not: ?]
                   )
                 ])

  defcombinatorp :parse_range,
                 parsec(:capture_char)
                 |> ignore(ascii_char([?-]))
                 |> parsec(:capture_char)
                 |> post_traverse(:wrap_range)

  defcombinatorp :parse_char_class,
                 ignore(ascii_char([?[]))
                 |> optional(ascii_char([?^]))
                 |> tag(:reverse)
                 |> times(
                   choice([
                     parsec(:parse_range),
                     parsec(:capture_char)
                   ]),
                   min: 1
                 )
                 |> ignore(ascii_char([?]]))
                 |> reduce(:tag_char_class)

  defparsec :parse, parsec(:parse_char_class) |> eos()

  defp escape_special_char([char]), do: Map.get(@special_char_map, char, char)

  defp wrap_range(_rest, [char2, char1], context, _line, _offset) do
    if char2 >= char1 do
      {[{:range, char1, char2}], context}
    else
      {:error, "Not in range #{[char1]} and #{[char2]}"}
    end
  end

  defp tag_char_class([{:reverse, [?^]} | rest]), do: {:comp_class, rest}
  defp tag_char_class([{:reverse, []} | rest]), do: {:char_class, rest}
end
