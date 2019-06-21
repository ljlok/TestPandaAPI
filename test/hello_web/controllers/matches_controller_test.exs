defmodule HelloWeb.MatchesControllerTest do
    use HelloWeb.ConnCase

    test "#matches/upcoming renders a list of 5 matches upcoming" do
        # match_as_json =
        #     %Match{id: 111, name: "xxx VS yyy"}
        #     |> List.wrap
        #     |> Poison.encode!

        response = build_conn(:get, "/api/matches/upcoming") |> send_request
        assert response.status == 200
        {:ok, body} = Poison.decode(response.resp_body)
        matches = body["matches"]
        assert length(matches) == 5

        Enum.each(matches, fn (match) -> 
            assert Map.has_key?(match, "id") 
            assert Map.has_key?(match, "name")
            assert Map.has_key?(match, "begin_at")
        end)
    end

    test "#matches/{id}/odd get odd for one match" do
        # test case 
        match_as_json = %{id: 384343, opponents: ["Hangzhou Spark", "Shanghai Dragons"]}

        response = build_conn(:get, "/api/matches/#{match_as_json.id}/odd") |> send_request
        assert response.status == 200 
        {:ok, odd} = Poison.decode(response.resp_body)
        Enum.any?(match_as_json.opponents, fn opponent -> assert Map.has_key?(odd, opponent) end)
        assert Enum.reduce(odd, 0, fn {_name, value}, acc -> acc + value end) == 100
    end

    defp send_request(conn) do
        conn
        |> put_private(:plug_skip_csrf_protection, true)
        |> HelloWeb.Endpoint.call([])
    end
end