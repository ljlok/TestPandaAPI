defmodule HelloWeb.MatchesController do
    use HelloWeb, :controller

    @weight_wins 0.3
    @weight_wins_opponent 0.7

    @doc """
    Get lastes 5 upcoming matches
    """
    def matches(conn, _params) do
        path = "matches/upcoming"
        query = "sort=-begin_at&page[number]=1&per_page=5"
        {:ok, matches} = MatchCache.Cache.fetch(path, fn ->
            request_panda_api(path, query)
        end) 
        render(conn, "index.json", matches: matches)
    end

    @doc """
    Get odd for one match
    """
    def odd(conn, %{"id" => id}) do
        path = "matches/#{id}"
        {:ok, match} = MatchCache.Cache.fetch(path, fn ->
            request_panda_api(path)
        end)
      
        # TODO check vars keyError
        opponents = match["opponents"]
        winner_name = match["winner"]["name"]
        if is_nil(opponents) or is_nil(match) do
            conn
            |> send_resp(404, "Match not found")
        end

        if winner_name do 
            # match finish
            loser_obj = hd(filter_opponent(opponents, winner_name))
            loser = loser_obj["opponent"]["name"]
            odd_result = %{winner_name => 1,  loser=> 0}
            json(conn, odd_result)
        else
            # Match upcoming
            teams = Enum.map(opponents, fn team -> Task.async(fn -> Map.put(team, "matches", get_stat(team["opponent"]["id"])) end) end)
            |> Enum.map(&Task.await/1)
            # Filter wins
            |> Enum.map(fn team -> Map.put(team, "name", team["opponent"]["name"]) 
            |> Map.put("wins", wins(team["matches"], team["opponent"]["id"])) end)  
            team_ids = get_opponents_ids(opponents)
            # Filter wins over opponent
            teams = Enum.map(teams, fn team ->
                other_team_id = List.delete(team_ids, team["id"])
                Map.put(team, "wins_over_opponents", Enum.filter(team["wins"], fn match -> 
                    Enum.any?(match["opponents"], fn opponent -> opponent["opponent"]["id"] == hd(other_team_id) end)
                end))
              end)
            total_wins_over_opponent = Enum.reduce(teams, 0, fn team, total -> total + length(team["wins_over_opponents"]) end)
            # Calculate odd
            odd = calculate_odd(teams, total_wins_over_opponent)
            json(conn, odd)
        end
    end

    @spec calculate_odd(List, integer) :: Map
    def calculate_odd(teams, total_wins_over_opponent) do
        odd = Enum.reduce(teams, %{}, fn team, acc -> 
            Map.put(acc, team["name"], 
            (((length(team["wins"]) + 1) / (length(team["matches"]) + 1)) * @weight_wins + 
            ((length(team["wins_over_opponents"]) + 1) / (total_wins_over_opponent + 1))) * @weight_wins_opponent  * 100) 
            end)
        total = Enum.reduce(odd, 0, fn {_name, value}, acc -> acc + value end)
        Enum.reduce(odd, %{}, fn {name, value}, acc -> Map.put(acc, name, value / total * 100) end)
    end

    def get_opponents_ids(opponents) do
        Enum.map(opponents, fn (x) -> x["opponent"]["id"] end)
    end

    @doc """
    Get team's finishd matches latest 100
    """
    @spec get_stat(integer) :: List
    def get_stat(id) do
        path = "teams/#{id}/matches"
        query = "sort=-begin_at&page[size]=100&filter[future]=false"
        {:ok, stat} = MatchCache.Cache.fetch(path, fn ->
            request_panda_api(path, query)
        end)
        stat
    end

    @spec get!(integer) :: Map
    def get!(id) do
        {:ok, match} = request_panda_api("matches/#{id}")
        match
    end

    @spec wins(List, integer) :: List
    def wins(matches, id) do
        Enum.filter(matches, fn match -> match["winner"] && match["winner"]["id"] == id end)
    end

    @spec request_panda_api(String, String) :: Map
    def request_panda_api(path, query \\ "") do
        base_url = Application.get_env(:hello, :base_url)
        token = Application.get_env(:hello, :api_token)

        url = "#{base_url}/#{path}?#{query}"
        headers = ["Authorization": "Bearer #{token}", "Accept": "Application/json; Charset=utf-8"]
        case HTTPoison.get(url, headers) do
            {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
                Poison.decode(body)
            {:error, %HTTPoison.Error{reason: reason}} ->
                IO.inspect reason # logging
                {:error, reason}
        end
    end

    @spec filter_opponent(List, String) :: List
    def filter_opponent(opponents, filter_name) do
        Enum.filter(opponents, fn(opponent) ->
            opponent["opponent"]["name"] != filter_name
        end)
    end
end