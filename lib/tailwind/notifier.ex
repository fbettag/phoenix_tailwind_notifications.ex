defmodule Tailwind.Notifier do
  @moduledoc """
  Helper to make useful notifications to be used in LiveView.

  It implements the to_flash/2 function to put flashes on the socket.

  ## Examples

  ```elixir
  defmodule MyWeb.Notifier do
    use Tailwind.Notifier, MyWeb.Gettext

    def action_to_icon(action) when is_atom(action) do
      case action do
        :deleted -> "fa fa-trash text-yellow-400"
        :created -> "fas fa-check text-green-400"
        :updated -> "fas fa-check text-green-400"
        :info -> "fa fa-info-circle text-green-400"
        :error -> "fa fa-exclamation-triangle text-red-400"
      end
    end

    defp model_id_name_link(%My.Accounts.User{id: id, name: name}), do: {gettext("User"), id, name, Routes...}
    defp model_id_name_link(%My.Customers.Customer{id: id, name: name}), do: {gettext("Customer"), id, name, Routes...}

    defp model_id_name_link(_), do: :bad_model
  end
  ```

  You can now use this Notfier in `Tailwind.Phoenix.Show` and `Tailwind.Phoenix.Index`.
  """

  @callback action_to_icon(any) :: String.t()

  @doc """
  When used, implements Helpers for notifications.
  """
  defmacro __using__(gettext) do
    quote do
      require Logger
      alias Phoenix.LiveView
      use Phoenix.HTML

      defp gettext(msg, opts \\ []), do: Gettext.gettext(unquote(gettext), msg, opts)

      def to_flash(%LiveView.Socket{} = socket, {:error, subject, message})
          when is_binary(subject) do
        payload = %{
          icon: action_to_icon(:error),
          subject: subject,
          message: message,
          close: gettext("Close")
        }

        LiveView.put_flash(socket, "error-#{:rand.uniform(100)}", payload)
      end

      def to_flash(%LiveView.Socket{} = socket, {:error, data, message}) do
        case model_id_name_link(data) do
          {model, id, name, _link} ->
            subject = gettext("Error while modifying %{model} %{name}", model: model, name: name)

            payload = %{
              icon: action_to_icon(:error),
              subject: subject,
              message: message,
              close: gettext("Close")
            }

            LiveView.put_flash(socket, "error-#{id}", payload)

          :bad_model ->
            Logger.error("Got unhandled Notifier data: #{inspect(data)}")
            socket
        end
      end

      def to_flash(%LiveView.Socket{} = socket, {action, data}) do
        case model_id_name_link(data) do
          {model, id, name, link} ->
            subject =
              gettext(
                "%{model} %{name} %{action} successfully",
                model: model,
                name: name,
                action: gettext(Atom.to_string(action))
              )

            message =
              gettext(
                "The %{model} with the ID %{id} has been %{action}",
                model: model,
                id: id,
                action: gettext(Atom.to_string(action))
              )

            button = ~E"""
              <i class="fa fa-eye mr-2"></i><%= gettext("View") %>
            """

            payload = %{
              icon: action_to_icon(action),
              subject: subject,
              message: message,
              close: gettext("Close")
            }

            payload =
              if action == :deleted,
                do: payload,
                else: Map.put(payload, :button, {button, link})

            LiveView.put_flash(socket, "#{action}-#{id}", payload)

          :bad_model ->
            Logger.error("Got unhandled Notifier data: #{inspect(data)}")
            socket
        end
      end

      def handle_info({action, _data} = msg, socket) when is_atom(action),
        do: {:noreply, to_flash(socket, msg)}
    end
  end

  use Phoenix.HTML

  @doc """
  Renders flash errors as drop in notifications.
  """
  def flash_errors(conn) do
    conn.private[:phoenix_flash]
    |> flash_live_errors()
  end

  @doc """
  Renders live flash errors as drop in notifications.
  """
  def flash_live_errors(nil), do: ~E""

  @doc """
  Renders live flash errors as drop in notifications.
  """
  def flash_live_errors(flashes) do
    ~E"""
    <div class="notifications">
      <%= for {id, flash} <- flashes do %>
        <div class="notification" id="notification-<%= id %>" x-data="{ show: false }" x-show="show"
          x-init="setTimeout(() => show = true, 10); setTimeout(() => show = false, 30000); "
          x-transition:enter="transition transform ease-out duration-300"
          x-transition:enter-start="opacity-0 translate-y-1"
          x-transition:enter-end="opacity-100 translate-y-0"
          x-transition:leave="transition transform ease-in duration-300"
          x-transition:leave-start="opacity-100 translate-y-0"
          x-transition:leave-end="opacity-0 translate-y-1">

          <div class="w-0 flex-1 p-4">
            <div class="flex items-start">
              <div class="flex-shrink-0 pt-0.5">
                <i class="<%= Map.get(flash, :icon, "") %>"></i>
              </div>
              <div class="content">
                <%= if Map.has_key?(flash, :subject) do %>
                  <p class="subject"><%= flash.subject %></p>
                <% end %>
                <%= if Map.has_key?(flash, :message) do %>
                  <p class="message"><%= flash.message %></p>
                <% end %>
              </div>
            </div>
          </div>
          <div class="flex">
            <div class="flex flex-col divide-y divide-gray-200">
              <%= if Map.has_key?(flash, :button) do %>
                <div class="h-0 flex-1 flex">
                  <%= link elem(flash.button, 0), to: elem(flash.button, 1), class: "view" %>
                </div>
              <% end %>
              <div class="h-0 flex-1 flex">
                <button x-on:click="show = false" class="close">
                  <i class="fa fa-times mr-2"></i> <%= flash.close %>
                </button>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
