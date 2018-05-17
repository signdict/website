use Bootleg.Config

role(
  :build,
  "signdict.org",
  user: System.get_env("bootleg_user"),
  workspace: "/tmp/bootleg/signdict/",
  silently_accept_hosts: true
)

task :phoenix_digest do
  alias Bootleg.UI

  mix_env = Keyword.get(config(), :mix_env, "prod")

  remote :build do
    "cd assets"
    "yarn || true"
    "npm run deploy || true"
    "cd .."
    "[ -d deps/phoenix ] && MIX_ENV=#{mix_env} mix phoenix.digest || true"
  end

  UI.info("Phoenix asset digest generated")
end

task :migrate do
  alias Bootleg.UI

  UI.info("Migrating database")

  remote :app, filter: [primary: true] do
    "bin/signdict migrate"
  end

  UI.info("Database migrated")
end

after_task(:compile, :phoenix_digest)
before_task(:start, :migrate)
