defmodule FastPostmanCollection.GenerateCollection do
  alias FastPostmanCollection.GenerateCollection.Structs.Event
  alias FastPostmanCollection.GenerateCollection.Structs.Info
  alias FastPostmanCollection.Config
  alias FastPostmanCollection.GenerateCollection.Structs.Auth
  alias FastPostmanCollection.GenerateCollection.Structs.Body
  alias FastPostmanCollection.GenerateCollection.Structs.Url
  alias FastPostmanCollection.GenerateCollection.Structs.Request
  alias FastPostmanCollection.GenerateCollection.Structs.Item
  alias FastPostmanCollection.CollectDataItem
  alias FastPostmanCollection.CollectDataModule
  alias FastPostmanCollection.GenerateCollection.Structs.Folder
  alias FastPostmanCollection.GenerateCollection.Structs.Main

  def generate(collected_data, attrs)
      when (is_list(collected_data) and is_map(attrs)) or is_list(attrs) do
    folders =
      FastPostmanCollection.Helpers.Map.prepare_folder(collected_data)
      |> FastPostmanCollection.Helpers.Map.to_keyword_list()
      |> recursive_build([])
      |> Enum.concat(get_extra_folders(attrs[:extra_folders]))

    %Main{
      item: folders,
      info: %Info{
        name: Config.get_name_collection()
      },
      variable: Auth.get_variables_tokens() ++ Config.get_variables()
    }
  end

  def generate_to_json(collected_data, attrs)
      when (is_list(collected_data) and is_map(attrs)) or is_list(attrs) do
    generate(collected_data, attrs)
    |> FastPostmanCollection.Helpers.Map.map_from_struct_recursive()
    |> Jason.encode!(pretty: true)
  end

  defp recursive_build([{key, value}], acc) when is_list(value) do
    [%Folder{name: key, item: recursive_build(value, [])} | acc]
  end

  defp recursive_build([{key, value} | t], acc) when is_list(value) do
    recursive_build(t, []) ++ [%Folder{name: key, item: recursive_build(value, [])} | acc]
  end

  defp recursive_build([{_key, value} | t], acc)
       when is_struct(value) do
    recursive_build(t, [parse_collect_data_module(value) | acc])
  end

  defp recursive_build([], acc) do
    acc
  end

  def parse_collect_data_module(item = %CollectDataModule{}) do
    %Folder{
      item: Enum.map(item.functions, &parse_collect_data_item/1),
      name: "#{item.title || item.module}"
    }
  end

  def parse_collect_data_item(item = %CollectDataItem{}) do
    %Item{
      name: "#{item.title || item.name}",
      request: %Request{
        method: item.method |> Atom.to_string() |> String.upcase(),
        body: Body.generate(item),
        url: Url.generate(item),
        header: item.headers || []
        # auth: Auth.generate(item)
      },
      event: Event.generate(item.doc_params)
    }
  end

  def get_extra_folders(nil), do: []
  def get_extra_folders(extra_folders) when is_list(extra_folders), do: extra_folders
  def get_extra_folders({module, fun}), do: apply(module, fun, [])
  def get_extra_folders({module, fun, args}), do: apply(module, fun, args)
end
