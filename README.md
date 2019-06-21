# Hello this is a PandaScore API test 

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Add pandaScore api_token in test.exs, dev.exs for dev mode
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`
  * Run controller tests by `mix test` and cache tests by `mix test lib/cache/cache_test.exs`
  * API Route1: `http://localhost:4000/api/matches/upcoming` for upcoming matches
  * API Route2: `http://localhost:4000/api/matches/384344/odd` for odd 
  * The algorith of odd is: 
  
  ```(percentage_wins_in_last_100_matches * weight1 + percentage_wins_over_opponent_in_last_100_matches * weight2) * 100%```
  * The 100 matches are all of finished and the recent 100 games are more representative of the team's recent situation
  * The `percentage_wins_over_opponent` is much more important so with a weight=0.7, it's just a method naive, better to ajust the param after dozens of experiments.
  * weight1 = 0.3 , weight2 = 0.7
  * I tried to use the stat-api for analysing the odd but have no auth

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
