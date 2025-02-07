defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Identicon.hello()
      :world

  """
  def hello do
    :world
  end

  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grig
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)

  end


  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color( color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end
    :egd.render(image)

  end

  def build_pixel_map(%Identicon.Image{grid: grid}=image) do
   pixel_map =  Enum.map grid , fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5)* 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end
    %Identicon.Image{image | pixel_map: pixel_map}

  end

  def filter_odd_squares(%Identicon.Image{grid: grid}= image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0 end
    %Identicon.Image{ image | grid: grid}
  end

  def pick_color(image) do
    # %Identicon.Image{hex: hex} = image
    #  Enum.take(hex, 3) otion 1
    # [Enum.at(hex, 0), Enum.at(hex, 1), Enum.at(hex, 2)] option 2
    # -------------------------------------------------
    # [r, g, b | _tail] = hex
    # [r, g, b]

    # Killer option
    %Identicon.Image{hex: [r, g, b | _tail]} = image
    %Identicon.Image{image | color: {r, g, b}}

  end

  def build_grig(%Identicon.Image{hex: hex}= image) do
   grid = hex
    |> Enum.chunk_every(3, 3, :discard)
    |> Enum.map(&mirror_row/1)
    |> List.flatten()
    |> Enum.with_index

    %Identicon.Image{image | grid: grid}

  end

  def mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]

  end

  def pick_color2(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def hash_input(input) do
   hex = :crypto.hash(:md5, input)
   |>:binary.bin_to_list()
   %Identicon.Image{hex: hex}
  end
end
