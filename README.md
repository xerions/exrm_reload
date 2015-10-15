# ExrmReload [![Build Status](https://travis-ci.org/xerions/exrm_reload.svg)](https://travis-ci.org/xerions/exrm_reload)

Build new sys.config from confrom config and apply it at runtume. 
It uses `conform_schema` and `conform_config` command line flags which are set on [exrm](https://github.com/bitwalker/exrm) startup script.

## Usage

1. Add exrm_reload to your list of dependencies in mix.exs:

    ```elixir
    def deps do
        [{:exrm_reload, github: "xerions/exrm_reload"}]
    end
    ```

2. Ensure exrm_reload is started before your application:

    ```elixir
    def application do
        [applications: [:exrm_reload]]
    end
    ```

3. Run reconfiguration when you want it:

    ```
    > ReleaseManager.Reload.run
    ```

or you can specify application's list for reconfiguration:

    > ReleaseManager.Reload.run [:hello, :exd, :ecdo]

It works with the releases are builded via `exrm`. You just call it by rpc from OS shell:

    $ you_application rpc ReleaseManager.Reload run
