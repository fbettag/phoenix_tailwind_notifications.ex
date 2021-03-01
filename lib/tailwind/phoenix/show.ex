defmodule Tailwind.Phoenix.Show do
  @moduledoc """
  Helper to make useful notifications to be used in LiveView show.ex files.

  It implements handle_info/2 LiveView callbacks for events,
  updates the current assigns if the notified object matches
  and redirects to the given URL-function if the current item gets deleted.

  The to function gets passed the socket as first and only parameter.
  This way you can use any assign in the socket to use the correct Route-helper.

  ## Examples

  ```elixir
  defmodule MyWeb.MyDataLive.Show do
    use MyWeb, :live_view

    use Tailwind.Phoenix.Show,
      notifier: MyWeb.Notifier,
      key: :data,
      pattern: %My.MyData{},
      to: &Routes.my_data_path(&1, :index)

    ...
  end
  ```
  """

  @doc """
  When used, implements handle_info/2 for show.ex
  """
  defmacro __using__(opts) do
    notifier = Keyword.get(opts, :notifier)
    assign_key = Keyword.get(opts, :key)
    data_pattern = Keyword.get(opts, :pattern)
    return_to_fn = Keyword.get(opts, :to)

    quote do
      @impl true
      def handle_info({:updated, unquote(data_pattern) = data} = msg, socket) do
        {:noreply,
         socket
         |> unquote(notifier).to_flash(msg)
         |> Tailwind.Phoenix.update_if_id(
           unquote(assign_key),
           socket.assigns[unquote(assign_key)].id,
           data
         )}
      end

      @impl true
      def handle_info({:deleted, unquote(data_pattern) = data} = msg, socket) do
        to = unquote(return_to_fn).(socket)

        {:noreply,
         socket
         |> Tailwind.Phoenix.redirect_if_id(socket.assigns[unquote(assign_key)].id, data, to: to)
         |> unquote(notifier).to_flash(msg)}
      end

      defdelegate handle_info(msg, socket), to: unquote(notifier)
    end
  end
end
