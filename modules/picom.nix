{ ... }:

{
  # Disabled - home-manager generates its own --config flag which conflicts
  # with our raw config. Picom is started from i3 startup instead.
  enable = false;
}
