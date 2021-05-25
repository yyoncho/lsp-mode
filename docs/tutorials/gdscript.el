(package-initialize)

(setq package-user-dir (expand-file-name "elpa2"
                                         user-emacs-directory))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

(package-refresh-contents)

(package-install 'quelpa)
(package-install 'dash)
(package-install 'f)
(package-install 'ht)
(package-install 'spinner)
(package-install 'markdown-mode)
(package-install 'lv)

(quelpa '(hydra :repo "yyoncho/lsp-mode" :fetcher github :branch "gdscript"))

(setq package-selected-packages '(yasnippet lsp-treemacs helm-lsp projectile hydra flycheck company avy which-key helm-xref dap-mode json-mode gdscript-mode))

(when (cl-find-if-not #'package-installed-p package-selected-packages)
  (mapc #'package-install package-selected-packages))

(helm-mode)
(require 'helm-xref)
(define-key global-map [remap find-file] #'helm-find-files)
(define-key global-map [remap execute-extended-command] #'helm-M-x)
(define-key global-map [remap switch-to-buffer] #'helm-mini)

(which-key-mode)
(add-hook 'gdscript-mode-hook #'lsp)
(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      company-idle-delay 0.0
      company-minimum-prefix-length 1
      lsp-enable-symbol-highlighting nil
      ;; lsp-diagnostics-provider :none
      lsp-signature-auto-activate nil
      lsp-eldoc-enable-hover nil
      lsp-enable-links nil
      create-lockfiles nil)

(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
  (yas-global-mode))
