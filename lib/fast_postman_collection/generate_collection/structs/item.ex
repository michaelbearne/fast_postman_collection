defmodule FastPostmanCollection.GenerateCollection.Structs.Item do
  defstruct [
    :name,
    :variable,
    :event,
    request: %FastPostmanCollection.GenerateCollection.Structs.Request{},
    protocolProfileBehavior: %{
      followRedirects: false
    }
  ]
end
