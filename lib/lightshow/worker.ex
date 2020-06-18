defmodule Lightshow.Worker do
  @moduledoc """
  Rainbow cycle based on https://learn.adafruit.com/adafruit-neopixel-uberguide/python-circuitpython
  """
  use GenServer

  alias Blinkchain.{Color, Point}

  defp led_count, do: Application.get_env(:lightshow, :led_count, 60)

  defmodule State do
    defstruct [:timer, :status, :lit_led]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, ref} = :timer.send_interval(33, :twinkle)

    state = %State{
      timer: ref,
      status: :ok,
      lit_led: 0
    }

    {:ok, state}
  end

  def handle_info(:chaser_sequence, state) do
    Blinkchain.fill(%Point{x: 0, y: 0}, led_count(), 1, %Color{g: 0, r: 0, b: 0})
    Blinkchain.set_pixel(%Point{x: state.lit_led, y: 0}, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int()
    })

    Blinkchain.render()
    lit_led = if (state.lit_led >= led_count()), do: 0, else: state.lit_led + 1
    {:noreply, %State{state | lit_led: lit_led}}
  end

  def handle_info(:complete_randomness, state) do
    Blinkchain.fill(%Point{x: 0, y: 0}, led_count(), 1, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int()
    })
    Blinkchain.render()
    {:noreply, state}
  end

  def handle_info(:twinkle, state) do
    Blinkchain.fill(%Point{x: 0, y: 0}, led_count(), 1, %Color{
      g: 0,
      r: 0,
      b: 0,
    })

    Blinkchain.set_pixel(%Point{x: random_int(), y: 0}, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int(),
    })

    Blinkchain.set_pixel(%Point{x: random_int(), y: 0}, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int(),
    })

    Blinkchain.set_pixel(%Point{x: random_int(), y: 0}, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int(),
    })

    Blinkchain.set_pixel(%Point{x: random_int(), y: 0}, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int(),
    })

    Blinkchain.render()
    {:noreply, state}
  end

  def handle_info(:rainbow_cycle, state) do
    for int <- 0..255 do
      for point <- 0..led_count() do
        pixel_index = (point * 256 / led_count()) + int
        Blinkchain.set_pixel(
          %Point{x: point, y: 0},
          wheel(
            Bitwise.band(pixel_index, 255)
          )
        )
      end
    end

    status = Blinkchain.render()
    {:noreply, %State{state | status: status}}
  end

  defp random_led do
    0..led_count()
    |> Enum.random()
  end

  defp random_int do
    1..255
    |> Enum.random()
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
