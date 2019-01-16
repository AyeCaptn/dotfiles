;;; config.el -*- lexical-binding: t; -*-

(add-hook 'after-init-hook #'magit-status)

(def-package! magit-gitflow
  :init (add-hook 'magit-mode-hook 'turn-on-magit-gitflow)
  :after magit)

;(defun ediff-copy-both-to-C ()
;  (interactive)
;  (ediff-copy-diff ediff-current-difference nil 'C nil
;                   (concat
;                    (ediff-get-region-contents ediff-current-difference 'A ediff-control-buffer)
;                    (ediff-get-region-contents ediff-current-difference 'B ediff-control-buffer))))
;
;(after! ediff
;    (map! :map ediff-mode-map
;          :nv "d" 'ediff-copy-both-to-C))
