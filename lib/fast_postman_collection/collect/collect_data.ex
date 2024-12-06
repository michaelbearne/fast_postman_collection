defmodule FastPostmanCollection.CollectDataItemParams do
  defstruct [
    :mode,
    :raw,
    :formdata,
    :body,
    :url_variable,
    :params,
    :auth_pre_request,
    :pre_request,
    :post_request,
    body_disabled: true
  ]

  def get_from_map(doc_params) when is_map(doc_params) do
    doc_params =
      doc_params
      |> Map.put_new(:mode, get_in(doc_params, [:postman, :mode]))
      |> Map.put_new(:raw, get_in(doc_params, [:postman, :raw]))
      |> Map.put_new(:formdata, get_in(doc_params, [:postman, :formdata]))
      |> Map.put_new(:body, get_in(doc_params, [:postman, :body]))
      |> Map.put_new(:url_variable, get_in(doc_params, [:postman, :url_variable]))
      |> Map.put_new(:params, get_in(doc_params, [:postman, :params]))
      |> Map.put_new(:pre_request, get_in(doc_params, [:postman, :pre_request]))
      |> Map.put_new(:post_request, get_in(doc_params, [:postman, :post_request]))
      |> Map.put_new(:body_disabled, get_in(doc_params, [:postman, :body_disabled]) || true)

    struct(__MODULE__, doc_params)
  end
end

defmodule FastPostmanCollection.CollectDataItem do
  defstruct [
    :title,
    :documentation,
    :name,
    :filter,
    :route,
    :method,
    :other_variables,
    :pipe_through,
    :headers,
    doc_params: %FastPostmanCollection.CollectDataItemParams{}
  ]
end

defmodule FastPostmanCollection.CollectDataModuleParams do
  defstruct [:folder_path, :filter]

  def get_from_map(doc_params) when is_map(doc_params) do
    struct(__MODULE__, doc_params)
  end
end

defmodule FastPostmanCollection.CollectDataModule do
  defstruct [
    :title,
    :documentation,
    :functions,
    :module,
    :other_variables,
    doc_params: %FastPostmanCollection.CollectDataModuleParams{}
  ]
end
