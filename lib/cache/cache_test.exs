defmodule MatchCacheTest do
    use ExUnit.Case
  
    test "#match odd caches and finds the correct data" do 
        slug = "matches/384343/odd"
        result = %{"Hangzhou Spark": 90.0453776872908, "Shanghai Dragons": 9.954622312709205}
        assert MatchCache.Cache.fetch(slug, fn ->
            result
            end) == result
  
        assert MatchCache.Cache.fetch(slug, fn -> "" end) == result
    end
  end