defmodule HelloWeb.MatchesView do
    use HelloWeb, :view

    def render("index.json", %{matches: matches}) do
        %{
            matches: Enum.map(matches, &matches_json/1)
        }
        # %{data: render_many(reviews, __MODULE__, "review.json")}
    end

    def matches_json(match) do
        %{
            begin_at: match["begin_at"],
            id: match["id"],
            name: match["name"]
        }
    end
end