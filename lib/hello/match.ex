defmodule HelloWeb.Match do
    use Ecto.Schema
  
    schema "matches" do
      field :name
  
      timestamps()
    end
  end