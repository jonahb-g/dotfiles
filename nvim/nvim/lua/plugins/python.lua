return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                -- Dawn's backend/ dir is the import root at runtime (backend/Makefile sets
                -- PYTHONPATH=.), but pyright's project root is the monorepo root (where
                -- pyproject.toml/.venv live). Without this, gd can't resolve
                -- models.x/services.x/routers.x/schemas.x imports. Harmless no-op in
                -- projects that don't have a backend/ dir.
                extraPaths = { "backend" },
              },
            },
          },
        },
      },
      setup = {
        pyright = function(_, opts)
          opts.before_init = function(_, config)
            -- Pin the interpreter to the monorepo's uv-managed .venv; without this
            -- basedpyright can't reliably auto-discover it and imports like sqlmodel
            -- resolve as missing everywhere.
            config.settings.python.pythonPath = config.root_dir .. "/.venv/bin/python"
          end
        end,
      },
    },
  },
}
