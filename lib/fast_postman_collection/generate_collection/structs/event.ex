defmodule FastPostmanCollection.GenerateCollection.Structs.Event do
  alias FastPostmanCollection.CollectDataItemParams
  defstruct listen: "test", script: %{}

  def generate(collect_item_params = %CollectDataItemParams{}) do
    generate_auth_pre_request(collect_item_params) ++ []
  end

  def generate_auth_pre_request(%CollectDataItemParams{
        pre_request: nil,
        post_request: post_request
      })
      when is_list(post_request) do
    [
      %__MODULE__{
        listen: "test",
        script: %{
          exec: post_request,
          type: "text/javascript"
        }
      }
    ]
  end

  def generate_auth_pre_request(%CollectDataItemParams{
        pre_request: pre_request,
        post_request: nil
      })
      when is_list(pre_request) do
    [
      %__MODULE__{
        listen: "prerequest",
        script: %{
          exec: pre_request,
          type: "text/javascript",
          packages: {}
        }
      }
    ]
  end

  def generate_auth_pre_request(%CollectDataItemParams{
        pre_request: pre_request,
        post_request: post_request
      })
      when is_list(pre_request) and is_list(post_request) do
    [
      %__MODULE__{
        listen: "test",
        script: %{
          exec: post_request,
          type: "text/javascript"
        }
      },
      %__MODULE__{
        listen: "prerequest",
        script: %{
          exec: pre_request,
          type: "text/javascript",
          packages: %{}
        }
      }
    ]
  end

  def generate_auth_pre_request(doc_params = %CollectDataItemParams{}) do
    is_enable = doc_params.auth_pre_request[:is_enabled] || false

    if is_enable do
      variable_token =
        doc_params.auth_pre_request[:variable_token] ||
          raise FastPostmanCollection.Expectation.GiveTokenAuth

      from_resp_token =
        doc_params.auth_pre_request[:from_resp_token] ||
          raise FastPostmanCollection.Expectation.GiveTokenAuth

      [
        %__MODULE__{
          listen: "test",
          script: %{
            exec: [
              "pm.test(\"Get token\", function () {\n",
              "    var jsonData = pm.response.json();",
              "    let bearerToken = jsonData.#{from_resp_token};",
              "    pm.collectionVariables.set(\"#{variable_token}\", bearerToken);",
              "});"
            ],
            type: "text/javascript"
          }
        }
      ]
    else
      []
    end
  end
end
