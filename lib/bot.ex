defmodule DiloBot.Bot do
  use Slack
  import String, only: [contains?: 2]

  import Application, only: [get_env: 2]

  @id              get_env(:dilo_bot, :id)
  @name            get_env(:dilo_bot, :bot_name)
  @reports_channel get_env(:dilo_bot, :reports_channel)

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(message = %{text: text, type: "message"}, slack, state) do
    unless message.user == @id do
      handle_slack_message(message, String.downcase(text), slack)
    end
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    IO.puts "Sending your message"

    send_message(text, channel, slack)
    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}


  def handle_slack_message(message, text, slack) do
    if DiloBot.WordlyWise.match?(text) do
      user = Slack.Web.Users.info(message.user)
      spawn(fn -> wordly_wise(user, message, slack) end)
    end
  end

  def wordly_wise(user, message, slack) do
    send_message("Generating wordly wise report...", message.channel, slack)
    indicate_typing(message.channel, slack)
    case DiloBot.WordlyWise.handle(message.channel) do
      {:ok, results} ->
        send_message("#{user["user"]["profile"]["first_name"]} asked me to generate this wordly wise report.", message.channel, slack)
        params = DiloBot.WordlyWise.message(results)
        Slack.Web.Chat.post_message(message.channel, "Wordly wise report for #{hd(results).name}:", params)
      {:error, error} ->
        send_message("Report generation failed! #{error}", message.channel, slack)
    end
  end
end
