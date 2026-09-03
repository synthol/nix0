{ settings, ... }:
{
  time.timeZone = settings.timeZone;
  i18n.defaultLocale = settings.locale;

  console.useXkbConfig = true;

  services.xserver.xkb = {
    layout = settings.xkbLayout;
    variant = settings.xkbVariant;
  };
}
