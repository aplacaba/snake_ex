defmodule ExSnake.Scene.Game do
  use Scenic.Scene
  alias Scenic.Graph
  alias Scenic.ViewPort

  import Scenic.Primitives

  # Constants
  @graph Graph.build(font: :roboto, font_size: 36)
  @tile_size 32
  @snake_starting_size 5
  @tile_radius 8

  def init(_arg, opts) do
    viewport = opts[:viewport]

    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)

    vp_tile_width = trunc(vp_width / @tile_size)
    vp_tile_height = trunc(vp_height / @tile_size)

    snake_start_coords = {
      trunc(vp_tile_width / 2),
      trunc(vp_tile_height / 2)
    }

    state = %{
      viewport: viewport,
      tile_width: vp_tile_width,
      tile_height: vp_tile_height,
      graph: @graph,
      score: 0,
      objects: %{
        snake: %{
          body: [snake_start_coords],
          size: @snake_starting_size,
          direction: {1,0}
        }
      }
    }

    state = Map.put(state, :graph,
      state.graph
      |> draw_score(state.score)
      |> draw_game_objects(state.objects))

    {:ok, state, push: state.graph}
  end

  def draw_score(graph, score) do
    graph
    |> text("Score: #{score}", fill: :white, translate: {@tile_size, @tile_size})
  end

  def draw_game_objects(graph, object_map) do
    Enum.reduce(object_map, graph, fn {object_type, object_data}, graph ->
      draw_object(graph, object_type, object_data)
    end)
  end

  defp draw_object(graph, :snake, %{body: snake}) do
    Enum.reduce(snake, graph, fn {x, y}, graph ->
      draw_tile(graph, x, y, fill: :lime)
    end)
  end

  def draw_tile(graph, x, y, opts) do
    tile_opts = Keyword.merge([fill: :white, translate: {x * @tile_size, y * @tile_size}], opts)
    graph |> rrect({@tile_size, @tile_size, @tile_radius}, tile_opts)
  end
end
