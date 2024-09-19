local vim = vim

return {
  "rest-nvim/rest.nvim",
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    opts = function(_, opts)
      opts.extensions = opts.extensions or {}
      opts.extensions.rest = {}
    end,
    config = function(_, opts)
      require("telescope").setup(opts)
      require("telescope").load_extension("rest")

      -- Create an autocommand group
      local rest_group = vim.api.nvim_create_augroup("RestNvim", { clear = true })

      -- Create an autocommand for .http files
      vim.api.nvim_create_autocmd("BufRead", {
        group = rest_group,
        pattern = "*.http",
        callback = function()
          -- Use vim.defer_fn to ensure Telescope is fully loaded
          vim.defer_fn(function()
            require("telescope").extensions.rest.select_env()
          end, 1000)
        end,
        desc = "Open Telescope REST env selector for .http files",
      })
    end,
    keys = {
      {
        "<leader>tr",
        function()
          require("telescope").extensions.rest.select_env()
        end,
        desc = "Select REST environment",
      },
    },
  },
}
