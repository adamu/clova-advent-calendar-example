defmodule Advent do
  use Clova

  def handle_launch(_req, resp) do
    resp
    |> add_speech("今日は#{say_date(today())}です")
    |> add_speech(days_to_christmas() |> say_days_to_christmas())
    |> add_speech(prompt_for_another())
  end

  def handle_intent("different_day", req, resp) do
    with potential_date when not is_nil(potential_date) <- get_slot(req, "date"),
         {:ok, date} <- Date.from_iso8601(potential_date) do
      resp
      |> add_speech("#{say_date(date)}まで計算しますか？")
      |> put_session_attributes(%{"date" => date})
      |> add_reprompt("#{date.month}月#{date.day}日まで計算したい場合、「はい」と言ってください。")
      |> add_reprompt(prompt_for_another())
    else
      _ -> add_speech(resp, "それは日付だと思いますがもっとわかりやすく言ってくださいね")
    end
  end

  def handle_intent("Clova.YesIntent", req, resp) do
    with %{"date" => iso_date} <- get_session_attributes(req),
         {:ok, date} <- Date.from_iso8601(iso_date) do
      resp
      |> add_speech(say_days_to(date))
      |> add_speech(prompt_for_another())
    else
      _ -> end_session(resp)
    end
  end

  def handle_intent(_name, _req, resp), do: end_session(resp)

  defp prompt_for_another(), do: "違う日まで計算したい場合、日付けを言ってください"

  defp say_days_to_christmas(0), do: "クリスマスの日です！メリークリスマス！"
  defp say_days_to_christmas(days) when days < 0, do: "クリスマスはもうすぎました。来年まで楽しみましょう。"
  defp say_days_to_christmas(days), do: "クリスマスまであと#{days}日です！"

  defp today, do: Timex.now("Asia/Tokyo") |> DateTime.to_date()

  defp say_date(date), do: "#{date.year}年#{date.month}月#{date.day}日"

  defp days_to(date), do: Date.diff(date, today())

  defp say_days_to(date), do: say_days_to(date, days_to(date))
  defp say_days_to(date, 0), do: "#{say_date(date)}は今日です！"
  defp say_days_to(date, days) when days < 0, do: "#{say_date(date)}から#{-days}日すぎました。"
  defp say_days_to(date, days), do: "#{say_date(date)}まであと#{days}日です。"

  defp days_to_christmas do
    {:ok, xmas} = Date.new(today().year, 12, 25)
    days_to(xmas)
  end
end
