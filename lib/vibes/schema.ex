defmodule Vibes.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @foreign_key_type :string
    end
  end
end
