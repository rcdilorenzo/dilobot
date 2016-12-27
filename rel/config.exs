use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :prod

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"%S{N.MOcIa044vcGaT`J$SZm3B!vc8;6}p$Q&Y7`*^mO*8hu.U@<s:(l5Z*sn2YX"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"$*m!WIddE5Vv=>O8.P$X4fDk`L{]?}s<LTimI>/(U^Ft(HL;gu%8Tc{!/p>UQU>)"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :dilo_bot do
  set version: current_version(:dilo_bot)
end

