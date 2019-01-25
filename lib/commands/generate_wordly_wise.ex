defmodule DiloBot.Command.GenerateWW do
  import Application, only: [get_env: 2]
  import DiloBot.WordlyWise, only: [available_channels: 0, generate: 1, message: 1]

  defstruct username: "", response_url: "", text: ""

  def parse_params(%{"channel_id" => channel_id, "response_url" => response_url, "text" => text}) do
    validate(channel_id, %__MODULE__{response_url: response_url, text: text})
  end

  def parse_params(_), do: {:error, "Unable to understand."}

  defp validate(channel_id, config) do
    mapping = get_env(:dilo_bot, :ww_channel_mapping)
    case Map.get(mapping, channel_id |> String.to_atom) do
      nil ->
        {:error, "Wordly wise generation only available in #{available_channels()}."}
      ww_username ->
        {:ok, %{config | username: ww_username}}
    end
  end

  def initial_response(%{username: username}) do
    "Generating Wordly Wise Report for #{username}..."
  end

  def process_error(%{"response_url" => url}, message) do
    post_message(url, %{text: message})
  end

  def process(%{username: username, response_url: url}) do
    case generate(username) do
      {:ok, results} ->
        post_message(url, message(results))
      {:error, error} ->
        post_message(url, %{text: error})
    end
  end

  defp post_message(url, body) do
    HTTPotion.post!(url, body: Poison.encode!(body), headers: ["Content-Type": "application/json"])
  end
end
