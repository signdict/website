defmodule SignDict.UpgradeCallbacks do
  import Gatling.Bash

  def before_mix_digest(env) do
    bash("yarn", ~w[], cd: env.build_dir)
    bash("npm", ~w[run deploy], cd: env.build_dir)
  end

  def before_upgrade_service(env) do
    bash("mix", ~w[ecto.migrate], cd: env.build_dir)
  end
end
