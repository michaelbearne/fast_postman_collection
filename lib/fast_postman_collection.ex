defmodule FastPostmanCollection do
  @cwd File.cwd!()
  @moduledoc File.read!(@cwd <> "/README.md")
  def generate(attrs \\ %{}) do
    FastPostmanCollection.Collect.generate_data_by_router()
    |> FastPostmanCollection.GenerateCollection.generate(attrs)
  end

  def generate_json(attrs \\ %{}) do
    extra = Application.get_env(:fast_postman_collection, :extra_folders, [])
    attrs = Map.put(attrs, :extra_folders, extra)

    FastPostmanCollection.Collect.generate_data_by_router()
    |> FastPostmanCollection.GenerateCollection.generate_to_json(attrs)
  end
end
