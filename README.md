# Tailwind Notifications for Phoenix Applications

This package implements helpers and macros for generating easy Notifications in LiveViews.

## Installation

This package can be installed by adding `phoenix_tailwind_notifications` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phoenix_tailwind_notifications, "~> 0.1"}
  ]
end
```

## Usage

```elixir
defmodule MyWeb.Notifier do
  use Tailwind.Notifier, MyWeb.Gettext

  defp model_id_name_link(%My.Accounts.User{id: id, name: name}), do: {gettext("User"), id, name, Routes...}
  defp model_id_name_link(%My.Customers.Customer{id: id, name: name}), do: {gettext("Customer"), id, name, Routes...}

  defp model_id_name_link(_), do: :bad_model
end

defmodule MyWeb.MyDataLive.Show do
  use MyWeb, :live_view

  use Tailwind.Phoenix.Show,
    notifier: MyWeb.Notifier,
    key: :data,
    pattern: %My.MyData{},
    to: &Routes.my_data_path(&1, :index)

  ...
end

defmodule MyWeb.MyDataLive.Index do
  use MyWeb, :live_view

  use Tailwind.Phoenix.Index,
    notifier: MyWeb.Notifier,
    key: :datas,
    data: %My.MyData{},
    value: &list_datas/1,
    to: &Routes.my_data_path(&1, :index)

  ...
end
```

Now you can replace your existing flash-helper functions with these two:

<%= Tailwind.Notifier.flash_errors(@conn) %>
<%= Tailwind.Notifier.flash_live_errors(@flash) %>


## Documentation

Documentation can be found at [https://hexdocs.pm/phoenix_tailwind_notifications](https://hexdocs.pm/phoenix_tailwind_notifications).
