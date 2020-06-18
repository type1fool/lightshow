defmodule Lightshow.Worker do
  use GenServer

  alias Blinkchain.{Color, Point}

  defp led_count, do: Application.get_env(:lightshow, :led_count, 60)

  defmodule State do
    defstruct [:timer, :colors, :iteration]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    {:ok, ref} = :timer.send_interval(250, :draw_frame)

    state = %State{
      timer: ref,
      iteration: 0,
      colors: Lightshow.Colors.colors()
    }

    {:ok, state}
  end

  def handle_info(:draw_frame, state) do
    for point <- 0..led_count() do
      Blinkchain.set_pixel(%Point{x: point, y: 0}, %Color{
        g: point + state.iteration,
        r: point + state.iteration * 2,
        b: point + state.iteration * 3,
      })
    end

    Blinkchain.render()
    {:noreply, %State{state | iteration: set_iteration(state.iteration) }}
  end

  defp set_iteration(iteration) do
    if iteration > 255 do
      0
    else
      iteration
    end
  end

  # def handle_info(:draw_frame, state) do
  #   [c1, c2, c3, c4, c5] = Enum.slice(state.colors, 0..4)

  #   tail = Enum.slice(state.colors, 1..-1)

  #   Blinkchain.copy(%Point{x: 0, y: 0}, %Point{x: 1, y: 0}, 7, 5)

  #   Blinkchain.set_pixel(%Point{x: 0, y: 0}, c1)
  #   Blinkchain.set_pixel(%Point{x: 1, y: 0}, c2)
  #   Blinkchain.set_pixel(%Point{x: 2, y: 0}, c3)
  #   Blinkchain.set_pixel(%Point{x: 3, y: 0}, c4)
  #   Blinkchain.set_pixel(%Point{x: 4, y: 0}, c5)

  #   Blinkchain.render()
  #   {:noreply, %State{state | colors: tail ++ [c1]}}
  # end
end
