defmodule Lightshow.Worker do
  @moduledoc """
  Rainbow cycle based on https://learn.adafruit.com/adafruit-neopixel-uberguide/python-circuitpython
  """
  use GenServer

  alias Blinkchain.{Color, Point}

  defp led_count, do: Application.get_env(:lightshow, :led_count, 60)

  defmodule State do
    defstruct [:timer]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, ref} = :timer.send_interval(33, :draw_frame)

    state = %State{
      timer: ref,
    }

    {:ok, state}
  end

  def handle_info(:draw_frame, state) do
    for hue <- 0..255 do
      for point <- 0..led_count() do
        Blinkchain.set_pixel(
          %Point{x: point, y: 0},
          wheel(
            Bitwise.band((point * 256) + hue, 255)
          )
        )
      end
    end

    Blinkchain.render()
    {:noreply, state}
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
      g: 255 - pos * 3,
      r: 0,
      b: 255 - pos * 3
    }
  end
end
