defmodule SignDict.DeployCallbacks do
  import Gatling.Bash

  def before_mix_digest(env) do
    # mkdir prevents complains about this directory not existing
    bash("mkdir", ~w[-p priv/static], cd: env.build_dir)
    bash("npm", ~w[install], cd: env.build_dir)
    bash("npm", ~w[run deploy], cd: env.build_dir)
  end
end

