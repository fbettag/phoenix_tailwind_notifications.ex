defmodule Tailwind.Phoenix do
  @moduledoc """
  Provides Helper functions to redirect away or update if a certain is is found.
  """

  @doc """
  Helper function to redirect if its id matches the given id for the given name.
  """
  def redirect_if_id(socket, needed_id, %{"id" => object_id}, to) do
    if object_id == needed_id,
      do: Phoenix.LiveView.push_redirect(socket, to),
      else: socket
  end

  def redirect_if_id(socket, needed_id, %{id: object_id}, to) do
    if object_id == needed_id,
      do: Phoenix.LiveView.push_redirect(socket, to),
      else: socket
  end

  def redirect_if_id(socket, _, _, _), do: socket

  @doc """
  Helper function to update object if its id matches the given id for the given name.
  """
  def update_if_id(socket, name, needed_id, %{"id" => object_id} = object) do
    if object_id == needed_id,
      do: Phoenix.LiveView.update(socket, name, fn _ -> object end),
      else: socket
  end

  def update_if_id(socket, name, needed_id, %{id: object_id} = object) do
    if object_id == needed_id,
      do: Phoenix.LiveView.update(socket, name, fn _ -> object end),
      else: socket
  end

  def update_if_id(socket, _, _, _), do: socket
end
