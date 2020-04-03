# Literate programming using LSP and org-mode
`lsp-mode` provides **experimental** support for running the language servers
inside of [org-mode](https://orgmode.org/) source blocks. `lsp-mode` is doing
that by obtaining the information about the source block and then translating
the point to the LSP positions back and forth so the server is which so the
server actually thinks that Emacs has opened the original file.


``` org
#+BEGIN_SRC python :tangle "python.py"
print "Hello!"
#+END_SRC
```

## What works
* lsp-mode core features (finding references, going to definitions, completion, lenses, etc)
* company-mode
* Flycheck
* lsp-treemacs-symbols

## What does not work
* lsp-treemacs-errros
* dap-mode
* lsp-ui
* flymake(?)
