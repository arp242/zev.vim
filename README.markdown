It's easy to change a lot of stuff with `:substitute`, but not always easy to
remember patterns for more complex substitutions.

zev.vim makes it easier to apply these kind of common substitutions. For
example, I might want to change:

    return errors.Wrap(err, "context")
    // to:
    return fmt.Errorf("context: %w", err)

With zev.vim you can define patterns:

    call zev#register('go', 'unwrap',
                \ 'Replace errors.Wrap() with stdlib fmt.Errorf()',
                \ '\verrors\.Wrap\((\k+), (["`])(.{-})["`]\)',
                \ 'fmt.Errorf(\2\3: %w\2, \1)')

Which can then easily be used with `:Zev unwrap`.

Command reference:

    :Zev  name[/flags]  Apply a registered pattern; the optional [flags] are
                        passed to the :substitute command (See :help s_flags).
                        For example ":Zev errctx/c" to confirm.
    :Zev! name[/flags]  Populate the commandline but don't do anything.
    :Zev                List registered patterns for the current filetype.
    :Zev!               List all registered patterns.

Zev defines a bunch of useful patterns (at least, useful for me) by default; use
`:Zev!` to list them all, and `let g:zev_no_default = 1` to disable this.

Please let me know if you come up with useful patterns so I can include them!

zev.vim is named after the main character in [*Remember*][1]. It's a good film;
you should watch it.

[1]: https://en.wikipedia.org/wiki/Remember_(2015_film)


Defining patterns
-----------------

Arguments accepted by `zev#register()`:

    filetype      Filetype to register the pattern for. Separate multiple with a
                  comma, or use an empty string to make it available for all
                  filetypes.

    name          The name as used with `:Zev name`.

    description   A description of what this does; not always easy to grok from
                  just the pattern.

    replace,      The replace and search patterns; a `:s/../../` command will
    search        be built from this. Don't include the delimiters and don't
                  escape `/` as `\/`, Zev will take care of this automatically
