(TeX-add-style-hook "mypack"
 (lambda ()
    (TeX-add-symbols
     '("bigslant" 2)
     '("ed" 1)
     '("todo" 1)
     "N"
     "Q"
     "R"
     "Z"
     "C"
     "itt"
     "ett"
     "mltt"
     "wig"
     "og"
     "wog"
     "wogs"
     "hott"
     "ott"
     "tig"
     "new")
    (TeX-run-style-hooks
     "xspace")))

