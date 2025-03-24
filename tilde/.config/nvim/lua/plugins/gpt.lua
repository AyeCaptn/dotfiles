return {
    -- {
    --     "nvim-cmp",
    --     dependencies = {
    --         "supermaven-inc/supermaven-nvim",
    --         -- build = ":SupermavenUseFree", -- remove this line if you are using pro
    --         opts = {
    --             ignore_filetypes = { cpp = true, markdown = true, txt = true },
    --             disable_inline_completion = true, -- disables inline completion for use with cmp
    --             log_level = "info",
    --         },
    --     },
    --     opts = function(_, opts)
    --         table.insert(opts.sources, 1, {
    --             name = "supermaven",
    --             group_index = 1,
    --             priority = 100,
    --         })
    --     end,
    -- },
    {
        "robitx/gp.nvim",
        config = function()
            local config = {
                providers = {
                    openai = {
                        endpoint = "https://api.openai.com/v1/chat/completions",
                        secret = { "cat", "/Users/sem/.openai" },
                    },
                    copilot = {
                        endpoint = "https://api.githubcopilot.com/chat/completions",
                        secret = {
                            "bash",
                            "-c",
                            "cat ~/.config/github-copilot/hosts.json | sed -e 's/.*oauth_token...//;s/\".*//'",
                        },
                    },
                },
                toggle_target = "vsplit",
                hooks = {
                    UnitTest = function(gp, params)
                        local system_prompt = "You are a coding assistant that specializes in generating Python unit tests using the pytest framework. Your task is to accept a piece of Python code and write unit tests that adhere to best practices. You should:\n\n"
                            .. "1. Use `pytest` conventions and syntax.\n"
                            .. "2. Implement fixtures where appropriate to set up any necessary test environment or data.\n"
                            .. "3. Follow unit testing best practices, such as testing one thing per test and ensuring tests are independent.\n"
                            .. "4. Use descriptive test names that start with `def test_`.\n"
                            .. "5. Ensure the tests are comprehensive and cover edge cases.\n"
                            .. "6. Provide meaningful assertions that validate the expected outcomes.\n"
                            .. "7. Make the code easy to understand and to read, avoid using comments."
                        local template = "Below is the code from {{filename}}. Please write the unit tests for the following code.\n\n"
                            .. "```{{filetype}}\n{{selection}}\n```"
                        local agent = gp.get_command_agent()
                        agent.system_prompt = system_prompt
                        gp.Prompt(params, gp.Target.vnew, agent, template, nil, nil, nil)
                    end,
                    PullRequest = function(gp, params)
                        local system_prompt = "You are a software engineer assistant specializing in code reviews and Git operations. Your task is to assist users in summarizing and validating changes made in a pull request (PR) by analyzing the Git diff from the current branch to the master branch. The PR is aimed at addressing a specific issue described in a ticket. Follow the template below to structure your response:\n\n"
                            .. "---\n\n"
                            .. "This is the template you need to fill out: \n\n"
                            .. "### 1. How does this PR address the issue described in the ticket?\n\n"
                            .. "   <summarization of key changes>"
                            .. "### 2. How can I validate this myself? Provide an example or process.\n\n"
                            .. "   <validation steps>"
                            .. "---\n\n"
                            .. "## Additional Guidance\n\n"
                            .. "- For step one of the template, summarize key changes:**\n"
                            .. "  - Identify and list the important code changes made in this PR.\n"
                            .. "  - Highlight any new features, bug fixes, or improvements.\n\n"
                            .. "- For step two of the template, list the validation steps:**\n"
                            .. "  - Outline clear and concise steps the user can take to validate the changes.\n"
                            .. "  - Provide examples, if possible, to illustrate the validation process.\n"
                            .. "  - List any API endpoints affected or introduced by the changes.\n"
                            .. "  - Provide example API calls, including request parameters and expected responses.\n\n"
                            .. "- Use precise and concise language to ensure clarity.\n"
                            .. "- Prioritize important changes and validation steps.\n"
                            .. "- Do not explain how to install, setup or run the project. The user is able to do this himself\n"
                            .. "- Avoid unnecessary technical jargon and focus on actionable information."
                        local prompt =
                            "Below is the diff of the changes. Please write the Pull Request description for the changes. Do not provide any additional information other than the Pull Request description. Write the Pull Request description"

                        local cmd =
                            "git diff --no-color --no-ext-diff master ':(exclude)*.lock' ':(exclude)package-lock.json'"
                        local handle = io.popen(cmd)
                        if not handle then
                            return nil
                        end

                        local diff = handle:read("*a")
                        handle:close()

                        if not diff or diff == "" then
                            return nil
                        end
                        local template = system_prompt .. "\n\n" .. prompt .. "\n\n" .. diff

                        local agent = gp.get_command_agent()
                        -- agent.system_promp = system_prompt
                        gp.Prompt(params, gp.Target.vnew, agent, template, nil, nil, nil)
                    end,
                    ReviewPullRequest = function(gp, params)
                        local system_prompt = "You are a software engineer assistant specializing in code reviews. Review the following pull request focusing on code quality, adherence to best practices, and potential performance issues. Highlight any areas where the code could be simplified, optimized, or improved in terms of readability, maintainability, and scalability. Ensure that the changes align with the project's coding standards and provide constructive feedback for any required revisions."
                            .. "\n\n"
                            .. "While reviewing make sure the code adhere to the following rules:\n"
                            .. "    - Use `import` statements for packages and modules only, not for individual types, classes, or functions.\n"
                            .. "	- Exceptions are allowed but must be used carefully.\n"
                            .. "	- Avoid mutable global state.\n"
                            .. "	- Nested local functions or classes are fine when used to close over a local variable. Inner classes are fine.\n"
                            .. "	- Comprehensions are allowed, however multiple `for` clauses or filter expressions are not permitted. Optimize for readability, not conciseness.\n"
                            .. "	- If a generator manages an expensive resource, make sure to force the clean up.\n"
                            .. "	- Lambda functions are can be used as one-liners. Prefer generator expressions over `map()` or `filter()` with a `lambda`.\n"
                            .. "	- Using a @property to control attribute access or to calculate a _trivially_ derived value.\n"
                            .. "	- Use the “implicit” false if at all possible.\n"
                            .. "	- Make sure all code is typed.\n"
                            .. "	- Avoid using the `+` and `+=` operators to accumulate a string within a loop. Add each substring to a list and `''.join` the list after the loop terminates.\n"
                            .. "	- Use a pattern-string (with %-placeholders) as their first argument for logging. Always call them with a string literal (not an f-string).\n"
                            .. "	- Explicitly close files and sockets when done with them.\n"
                            .. "	- Use `TODO` comments for code that is temporary, a short-term solution, or good-enough but not perfect.\n"
                            .. "	- The code must be well-designed and appropriate for the system.\n"
                            .. "	- The code must behave as intended.\n"
                            .. "	- Could the code be made simpler? Would another developer be able to easily understand and use this code when they come across it in the future?\n"
                            .. "	- The code has clear names for variables, classes, methods, etc...\n"
                            .. "	- The comments are clear and useful.\n"
                            .. "\n\n"
                            .. "When reviewing unit tests, make sure the tests adhere to the following rules:\n"
                            .. "    - Make sure the test is  clear, concise, and readable. Use descriptive names for test methods and provide meaningful comments when necessary.\n"
                            .. "    - Aim for only one assertion per test method to help isolating failures and to make it easier to identify the specific condition that caused the failure.\n"
                            .. "    - Ensure each test is independent and does not rely on the state or results of other tests. \n"
                            .. "    - Make sure that the changes by this PR are covered by the tests. Look for typical cases, edge cases, and error conditions. Aim to cover all branches and possible execution paths of the new code.\n"
                            .. "    - Ensure that tests are isolated from external dependencies, such as databases, web services, or file systems. Make sure techniques like mocking or dependency injection are used.\n"
                        local prompt =
                            "Below is the diff of the changes. Review the changes made to the code. Only comment on code that does not adhere to the rules or best practices. Place the code block you are commenting on inline."

                        local cmd =
                            "git diff --no-color --no-ext-diff --unified=0 --no-prefix master ':(exclude)*.lock' ':(exclude)package-lock.json'"
                        local handle = io.popen(cmd)
                        if not handle then
                            return nil
                        end

                        local diff = handle:read("*a")
                        handle:close()

                        if not diff or diff == "" then
                            return nil
                        end
                        local template = system_prompt .. "\n\n" .. prompt .. "\n\n" .. diff

                        local agent = gp.get_command_agent()
                        -- agent.system_promp = system_prompt
                        gp.Prompt(params, gp.Target.vnew, agent, template, nil, nil, nil)
                    end,
                },
                agents = {
                    {
                        provider = "copilot",
                        name = "CopilotChatGPT4o",
                        chat = true,
                        command = false,
                        -- string with model name or table with model name and parameters
                        model = { model = "gpt-4o", temperature = 1.1, top_p = 1 },
                        -- system prompt (use this to specify the persona/role of the AI)
                        system_prompt = string.format(
                            [[You are an AI programming assistant.
                            Follow the user's requirements carefully & to the letter.
                            Keep your answers short and impersonal.
                            You can answer general programming questions and perform the following tasks: 
                            * Ask a question about the files in your current workspace
                            * Explain how the code in your active editor works
                            * Generate unit tests for the selected code
                            * Propose a fix for the problems in the selected code
                            * Scaffold code for a new workspace
                            * Find relevant code to your query
                            * Propose a fix for the a test failure
                            * Ask questions about Neovim
                            First think step-by-step - describe your plan for what to build in pseudocode, written out in great detail.
                            Then output the code in a single code block. This code block should not contain line numbers (line numbers are not necessary for the code to be understood, they are in format number: at beginning of lines).
                            Minimize any other prose.
                            Use Markdown formatting in your answers.
                            Make sure to include the programming language name at the start of the Markdown code blocks.
                            Avoid wrapping the whole response in triple backticks.
                            The user works in an IDE called Neovim which has a concept for editors with open files, integrated unit test support, an output pane that shows the output of running the code as well as an integrated terminal.
                            The user is working on a %s machine. Please respond with system specific commands if applicable.
                            The active document is the source code the user is looking at right now.
                            You can only give one reply for each conversation turn.
                            ]],
                            vim.loop.os_uname().sysname
                        ),
                    },
                    {
                        name = "ChatGPT3-5",
                        disable = true,
                    },
                    {

                        name = "CodeGPT3-5",
                        disable = true,
                    },

                    {
                        name = "ChatGPT4o-mini",
                        disable = true,
                    },
                    {
                        provider = "openai",
                        disable = true,
                        name = "CodeGPT4o",
                        chat = false,
                        command = true,
                        -- string with model name or table with model name and parameters
                        model = { model = "gpt-4o", temperature = 0.8, top_p = 1 },
                        -- system prompt (use this to specify the persona/role of the AI)
                        system_prompt = require("gp.defaults").code_system_prompt,
                    },
                    {
                        provider = "copilot",
                        disable = false,
                        name = "CopilotGPT4o",
                        chat = false,
                        command = true,
                        -- string with model name or table with model name and parameters
                        model = { model = "gpt-4o", temperature = 0.8, top_p = 1 },
                        -- system prompt (use this to specify the persona/role of the AI)
                        system_prompt = require("gp.defaults").code_system_prompt,
                    },
                    {
                        name = "CodeGPT4o-mini",
                        disable = true,
                    },
                },
            }
            require("gp").setup(config)

            -- or setup with your own config (see Install > Configuration in Readme)
            -- require("gp").setup(config)

            -- shortcuts might be setup here (see Usage > Shortcuts in Readme)
        end,
        keys = {
            {
                "<leader>an",
                "<cmd>GpChatNew<cr>",
                desc = "New Chat",
            },
            {
                "<leader>at",
                "<cmd>GpChatToggle<cr>",
                desc = "Toggle Chat",
            },
            {
                "<leader>af",
                "<cmd>GpChatFind<cr>",
                desc = "Find Chat",
            },
            {
                "<leader>au",
                "<cmd>GpUnitTest<cr>",
                desc = "Generate Unit Test",
            },
        },
    },
}
