use Bootleg.DSL

config(:refspec, "main")

role(
  :build,
  "signdict.org",
  user: System.get_env("bootleg_user"),
  workspace: "/tmp/bootleg/signdict/",
  silently_accept_hosts: true
)

task :download_ua_files do
  alias Bootleg.UI

  mix_env = Keyword.get(config(), :mix_env, "prod")

  remote :build do
    "[ -d deps/phoenix ] && MIX_ENV=#{mix_env} mix ua_inspector.download --force || true"
  end

  UI.info("UserAgent database downloaded")
end

task :phoenix_digest do
  alias Bootleg.UI

  mix_env = Keyword.get(config(), :mix_env, "prod")

  remote :build, cd: "assets" do
    "yarn || true"
    "yarn run deploy || true"
  end

  remote :build do
    "[ -d deps/phoenix ] && MIX_ENV=#{mix_env} mix phx.digest || true"
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

after_task(:compile, :download_ua_files)
after_task(:compile, :phoenix_digest)
before_task(:start, :migrate)
