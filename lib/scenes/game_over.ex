defmodule ExSnake.Scene.GameOver do
  use Scenic.Scene
  alias Scenic.Graph
  alias Scenic.ViewPort

  import Scenic.Primitives

  @text_opts [id: :gameover, fill: :white, text_align: :center]

  @graph Graph.build(font: :roboto, font_size: 36, clear_color: :black)
  |> text("Game Over", @text_opts)

  @game_scene ExSnake.Scene.Game

  def init(score, opts) do
    viewport = opts[:viewport]
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    position = {vp_width / 2, vp_height / 2}

    graph = Graph.modify(@graph, :gameover, &update_opts(&1, translate: position))

    state = %{
      graph: graph,
      viewport: opts[:viewport],
      on_cooldown: true,
      score: score
    }

    Process.send_after(self(), :end_cooldown, 2000)
    {:ok, state}
  end

  def handle_info(:end_cooldown, state) do
    graph = state.graph
    |> Graph.modify(:gameover, &text(&1, "Game Over! \n"
                                      <> "You scored #{state.score}.\n"
                                      <> "Presse any key to try again.",
                                      @text_opts))

    {:noreply, %{state | on_cooldown: false}, push: graph}
  end

  def handle_input({:key, _}, _context, %{on_cooldown: false} = state) do
    restart_game(state)
    {:noreply, state}
  end

  def handle_input(_input, _context, state), do: {:noreply, state}

  defp restart_game(%{viewport: vp}) do
    ViewPort.set_root(vp, {@game_scene, nil})
  end
end
