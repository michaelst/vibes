# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Vibes.Repo.insert!(%Vibes.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
%{
  title: "Vibes MegaMart",
  subtitle: "the grocer's greatest earworms",
  tracks_per_user: 7,
  status: "active"
}
|> Vibes.Challenges.Challenge.changeset()
|> Vibes.Repo.insert!()
