defmodule Lightshow.Worker do
  use GenServer

  alias Blinkchain.Point

  defmodule State do
    defstruct [:timer, :colors]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, ref} = :timer.send_interval(33, :draw_frame)

    state = %State{
      timer: ref,
      colors: Lightshow.colors()
    }

    {:ok, state}
  end

  def handle_info(:draw_frame, state) do
    [c1, c2, c3, c4, c5] = Enum.slice(state.colors, 0..4)

    tail = Enum.slice(state.colors, 1..-1)

    Blinkchain.copy(%Point{x: 0, y: 0}, %Point{x: 1, y: 0}, 7, 5)

    Blinkchain.set_pixel(%Point{x: 0, y: 0}, c1)
    Blinkchain.set_pixel(%Point{x: 0, y: 1}, c2)
    Blinkchain.set_pixel(%Point{x: 0, y: 2}, c3)
    Blinkchain.set_pixel(%Point{x: 0, y: 3}, c4)
    Blinkchain.set_pixel(%Point{x: 0, y: 4}, c5)

    Blinkchain.render()
    {:noreply, %State{state | colors: tail ++ [c1]}}
  end
end
