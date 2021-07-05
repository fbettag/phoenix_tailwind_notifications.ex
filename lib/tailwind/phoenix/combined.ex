defmodule Tailwind.Phoenix.Combined do
  @moduledoc """
  Helper to make useful notifications to be used in LiveView controllers where
  Index and Show is combined.

  It implements handle_info/2 LiveView callbacks for events,
  updates the current assigns if a notification arrives.

  The value function gets passed the socket as first and only parameter.
  This way you can use any assign in the socket to use the correct query.

  ## Examples

  ```elixir
  defmodule MyWeb.MyDataLive.Combined do
    use MyWeb, :live_view

    use Tailwind.Phoenix.Combined,
      notifier: MyWeb.Notifier,
      key_index: :datas,
      key_show: :data,
      data: %My.MyData{},
      value_index: &list_datas/1,
      to: &Routes.my_data_path(&1, :index)

    ...
  end
  ```
  """

  @doc """
  When used, implements handle_info/2 for index.ex.
  """
  defmacro __using__(opts) do
    notifier = Keyword.get(opts, :notifier)
    index_assign_key = Keyword.get(opts, :key_index)
    show_assign_key = Keyword.get(opts, :key_show)
    data_pattern = Keyword.get(opts, :pattern)
    assign_value_fn = Keyword.get(opts, :value)
    return_to_fn = Keyword.get(opts, :to)

    quote do
      @impl true
      def handle_info({:deleted, unquote(data_pattern) = data} = msg, socket) do
        socket =
          if socket.assigns[unquote(show_assign_key)] == nil do
            socket
          else
            to = unquote(return_to_fn).(socket)

            socket
            |> Tailwind.Phoenix.redirect_if_id(socket.assigns[unquote(show_assign_key)].id, data,
              to: to
            )
            |> unquote(notifier).to_flash(msg)
          end

        socket =
          if socket.assigns[unquote(index_assign_key)] == nil do
            socket
          else
            socket
            |> unquote(notifier).to_flash(msg)
            |> update(unquote(index_assign_key), fn _ -> unquote(assign_value_fn).(socket) end)
          end

        {:noreply, socket}
      end

      @impl true
      def handle_info({action, unquote(data_pattern) = data} = msg, socket) do
        socket =
          if socket.assigns[unquote(show_assign_key)] == nil do
            socket
          else
            socket
            |> unquote(notifier).to_flash(msg)
            |> Tailwind.Phoenix.update_if_id(
              unquote(show_assign_key),
              socket.assigns[unquote(show_assign_key)].id,
              data
            )
          end

        socket =
          if socket.assigns[unquote(index_assign_key)] == nil do
            socket
          else
            socket
            |> unquote(notifier).to_flash(msg)
            |> update(unquote(index_assign_key), fn _ -> unquote(assign_value_fn).(socket) end)
          end

        {:noreply, socket}
      end

      defdelegate handle_info(data, socket), to: unquote(notifier)
    end
  end
end
