defmodule Lightshow.Colors do
  alias Blinkchain.Color

  @doc """
  Get a list of nice-looking rainbow colors.
  """
  def rainbow(led_count) do
    spectrum =
      for int <- 0..255 do
        for point <- 0..led_count do
          pixel_index = Integer.floor_div(point * 256, led_count) + int
          wheel(Bitwise.band(pixel_index, 255))
        end
      end

    spectrum
    |> List.flatten()
  end

  defp wheel(pos) when pos < 0 or pos > 255 do
    %Color{g: 0, r: 0, b: 0}
  end

  defp wheel(pos) when pos < 85 do
    %Color{
      g: 255 - pos * 3,
      r: pos * 3,
      b: 0
    }
  end

  defp wheel(pos) when pos < 170 do
    pos = pos - 85

    %Color{
      g: 0,
      r: 255 - pos * 3,
      b: pos * 3
    }
  end

  defp wheel(pos) do
    pos = pos - 170

    %Color{
      g: pos * 3,
      r: 0,
      b: 255 - pos * 3
    }
  end
end
