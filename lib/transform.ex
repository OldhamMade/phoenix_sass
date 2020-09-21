defmodule PhoenixSass.Transform do
  defstruct [
    :root,
    :src,
    :srcdir,
    :subdir,
    :basename,
    :destdir,
    :dest,
    :opts,
    :sass,
    :result,
  ]
end
