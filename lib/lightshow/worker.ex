defmodule Lightshow.Worker do
  @moduledoc """
  Rainbow cycle based on https://learn.adafruit.com/adafruit-neopixel-uberguide/python-circuitpython
  """
  use GenServer

  alias Blinkchain.{Color, Point}
  alias Lightshow.Colors

  @led_count Application.get_env(:lightshow, :led_count, 61)
  @rainbow_colors Colors.rainbow(@led_count)

  defmodule State do
    defstruct [:timer, :lit_led]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    test_leds()
    render_rainbow()

    {:ok, ref} = :timer.send_interval(33, :shift_pixels)

    state = %State{
      timer: ref,
      lit_led: 0
    }

    {:ok, state}
  end

  def handle_info(:shift_pixels, state) do
    Blinkchain.copy({@led_count - 1, 0}, {0, 0}, 1, 1)
    Blinkchain.copy({0, 0}, {1, 0}, @led_count - 1, 1)
    Blinkchain.render()
    {:noreply, state}
  end

  def handle_info(:chaser_sequence, state) do
    Blinkchain.fill(%Point{x: 0, y: 0}, @led_count, 1, %Color{g: 0, r: 0, b: 0})

    Blinkchain.set_pixel(%Point{x: state.lit_led, y: 0}, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int()
    })

    Blinkchain.render()
    lit_led = if state.lit_led >= @led_count, do: 0, else: state.lit_led + 1
    {:noreply, %State{state | lit_led: lit_led}}
  end

  def handle_info(:complete_randomness, state) do
    Blinkchain.fill(%Point{x: 0, y: 0}, @led_count, 1, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int()
    })

    Blinkchain.render()
    {:noreply, state}
  end

  def handle_info(:twinkle, state) do
    Blinkchain.fill(%Point{x: 0, y: 0}, @led_count, 1, %Color{
      g: 0,
      r: 0,
      b: 0
    })

    Blinkchain.set_pixel(%Point{x: random_int(), y: 0}, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int()
    })

    Blinkchain.set_pixel(%Point{x: random_int(), y: 0}, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int()
    })

    Blinkchain.set_pixel(%Point{x: random_int(), y: 0}, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int()
    })

    Blinkchain.set_pixel(%Point{x: random_int(), y: 0}, %Color{
      g: random_int(),
      r: random_int(),
      b: random_int()
    })

    Blinkchain.render()
    {:noreply, state}
  end

  def test_leds do
    Blinkchain.fill({0, 0}, @led_count, 1, {255, 0, 0})
    Blinkchain.render()
    :timer.sleep(500)
    Blinkchain.fill({0, 0}, @led_count, 1, {0, 255, 0})
    Blinkchain.render()
    :timer.sleep(500)
    Blinkchain.fill({0, 0}, @led_count, 1, {0, 0, 255})
    Blinkchain.render()
    :timer.sleep(500)
  end

  defp render_rainbow do
    for i <- 0..@led_count do
      selected_color = Enum.at(@rainbow_colors, i, %Color{g: 0, r: 0, b: 0})
      Blinkchain.set_pixel(%Point{x: i, y: 0}, selected_color)
    end

    Blinkchain.render()
  end

  defp random_led do
    0..@led_count
    |> Enum.random()
  end

  defp random_int(min \\ 1, max \\ 255) do
    min..max
    |> Enum.random()
  end
end
