# ExrmReload

Build new sys.config from confrom and apply it in runtume. 
It uses `conform_schema` and `conform_config` command line flags which are set on [exrm](https://github.com/bitwalker/exrm) startup script.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add exrm_reload to your list of dependencies in mix.exs:

        def deps do
          [{:exrm_reload, "~> 0.0.1"}]
        end

  2. Ensure exrm_reload is started before your application:

        def application do
          [applications: [:exrm_reload]]
        end
