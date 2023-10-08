defmodule RegexParser do
  import NimbleParsec

  defparsec(
    :parse_hex,
    ignore(string("\\"))
    |> choice([
      ignore(string("x"))
      |> ascii_char([?0..?9, ?a..?f, ?A..?F])
      |> ascii_char([?0..?9, ?a..?f, ?A..?F]),
      ignore(string("{"))
      |> ascii_char([?0..?9, ?a..?f, ?A..?F])
      |> repeat(ascii_char([?0..?9, ?a..?f, ?A..?F]))
      |> ignore(string("}"))
    ])
    |> reduce({:to_hex, []})
  )

  defp to_hex(args) do
    List.to_integer(args, 16)
  end
end
