::
::
::
/?    310
/+  sole, prey
:: !:
[. sole]
=>  |%
    :>  #  %model
    +|
    +=  state
      $:  tabla=table
          wom=(unit ship)
          soles=(map bone sole-share)
          tabla=table
          board=(map spot player)
          toer=player
      ==
    +=  move  (pair bone card)
    +=  card  $%  [%diff %sole-effect sole-effect]
                  [%wait wire p=@da]
                  [%peer wire dock path]
              ==
    +=  action  $%  [%sub @p]                      ::  subscribe to a game on @p
                    [%disc ~]                      ::  disconnect from a game
                ==
    +=  table   [%tan rows=(list row)]
    +=  row     [%leaf tape]
    +=  outcome  ?(%wins %tie ~)
    +=  turno  [=player =spot]
    +=  player  ?(%x %o %$)
    +=  spot  [x=num y=num]
    +=  num  ?(%1 %2 %3)
    :>  #
    :>  #  %constant
    :>  #
    :>  constants, in their own chapter.
    +|
    ++  row-sep  leaf+" ---------"
    ++  texto    txt+"¡hola terricola!"
    ++  claro    clr+~
    ++  tong     bel+~
    ++  barra    '/'
    --
::
::  app logic
::
|_  [bol=bowl:gall state]
::
++  prep
  :: TODO: "always reset state no matter what" is ++ prep `_.
  |=  *
  ^-  (quip move _+>)
  ~&  [%starto1 tabla]
  [~ +>.$(toer ?:(=(toer %x) %o %x))]
::
++  wake                                                ::>  kicked by timer
  |=  [wir=wire ~]
  ^-  (quip move _+>)
  ~&  [%wake wir]
  [~ +>.$]
::
++  active-toer  (player-icon [~ toer])
++  switch  ?:(=(toer %o) %x %o)
++  last-toer  (player-icon [~ switch])
::
++  coup-noun
  |=  [wir=wire err=(unit tang)]
  ?~  err  ~&([%no-error wir] [~ +>])
  ~&  [%error err]
  [~ +>]
::
++  diff-sole
  |=  [wir=wire dat=*]
  ~&  [%got-data-sole wir dat]
  [~ +>]
::
++  diff-sole-effect
  |=  [wir=wire dat=*]
  ~&  [%got-data-sole-effect wir dat]
  [~ +>]
::
++  prompt
  ^-  sole-prompt
  [& %ask-ship " ['{active-toer}' ~] (row/col): "]
::
++  peer-sole
  |=  path
  ~&  [%peer-sole-mio path]
  ^-  (quip move _+>)
  =.  tabla  [%tan (flop print-board)]
  :_  +>.$(soles (~(put by soles) ost.bol *sole-share))
  =-  [(effect %mor pro+prompt -)]~
  [tabla ~]
::
++  poke-noun
  |=  act=*
  ^-  (quip move _+>)
  [~ +>]
::
++  min-gate
  |=  [ost=bone re=*]
  ^-  move
  (effect texto)
::
++  effect  |=(fec/sole-effect [ost.bol %diff %sole-effect fec])
::
++  min-sole  (prey /sole bol)
::
++  num-rule  (shim '1' '3')
++  indice  (cook |=(a/@ (sub a '0')) num-rule)
++  position  ;~((glue fas) indice indice)           :: [1-3]/[1-3]
::
++  spot-val
  |=  a=[@ @]
  ?>(?=(spot a) a) :: If assertion is true, return the input. model validation
::
++  poke-sole-action
  |=  act=sole-action
  ^-  (quip move _+>)
  =/  som  (~(got by soles) ost.bol)
  ?-    -.act
      $clr  [~ +>.$]                                           :: clear screen
      $ret                                                     :: enter
    ?:  =(~ buf.som)
      :_  +>.$
      [(effect txt+"position for '{active-toer}' (e.g. 1/1)  ")]~
    =/  try  (rust (tufa buf.som) position)
    ?~  try
      [~ +>.$]
    =/  spo  (spot-val u.try)
    ?:  (~(has by board) spo)
      :_  +>.$
      [(effect txt+" Spot taken ")]~
    ~&  [%bef board]
    =^  out  board  (step [toer spo])
    ~&  [%taf board]
    =.  toer  switch
    =.  tabla  [%tan (flop print-board)]
    ?~  out                                                   :: game goes on
      :_  +>.$
      =-  [(effect %mor pro+prompt -)]~
      [tabla ~]
    =/  outcome  :-  %txt
    %+  weld  " End game:  "
    ?:(=(out %tie) "it's a tie" (weld last-toer " wins!"))
    :_  +>.$(board *(map spot player))                        :: cleaning up
    =-  [(effect %mor outcome -)]~
    [pro+prompt tabla ~]
      $det                                                    :: key press
    =^  inv  som  (~(transceive sole som) +.act)              :: new edit & inv?
    =.  soles  (~(put by soles) ost.bol som)                  :: accumulate edit
    [~ +>.$]
  ==
::
++  players-in-row
  |=  ro=num
  =/  col  1
  |-   ^-  (list player)
  ?:  =(4 col)
    ~
  :-
    ?~  (~(get by board) [3 3])
      %$
    %x
  $(col (add col 1))
::
++  player-icon
  |=  per=(unit player)
  ^-  tape
  ?-  per
    ~   " "
    [~ %o]  "O"
    [~ %$]  " "
    [~ %x]  "X"
  ==
::
++  tas-player
  |=  a=tape
  ^-  (unit player)
  :-  ~
  ?:  =(a "O")
    %o
  ?:  =(a " ")
    %$
  ?:  =(a "X")
    %x
  %$
::
++  player-pos
  |=  [ro=@ co=@]  ^-  tape
  =+  player=(~(get by board) [ro co])
  (player-icon player)
::
++  print-row
  |=  ro=@  ^-  row
  =/  co  1
  :-  %leaf
  %-  zing
  |-
  =/  player  (player-pos [ro co])
  ?:  ?&(=(%4 co))
    ~
  :-
    ?:  ?&(=(co %1))
      (weld (weld " " player) " ")
    ?:  ?&(=(co %2))
      (weld (weld "| " player) " ")
    ?:  ?&(=(co %3))
      (weld (weld "| " player) " ")
    ~
    $(co (add co 1))
::
++  print-board
  |-  ^-  (list row)
  =/  ro  1
  |-
  ?:  =(ro 4)
    [leaf+"" ~]
  ?:  ?&(=(ro 3))
    [(print-row ro) $(ro (add ro 1))]
  [(print-row ro) row-sep $(ro (add ro 1))]
::
++  step
  |=  turn=turno
  ^-  [outcome (map spot player)]
  =.  board  (~(put by board) [spot.turn player.turn])
  [outcome-check board]
::
++  outcome-check
  ^-  outcome
  ?:  win-check
    %wins
  ?:(tie-check %tie ~)
::
++  win-check
  =/  who=player  toer
  %+  lien  winning-rows
  |=  a=(list spot)
  %+  levy  a
  |=  b=spot
  =/  c=(unit player)  (~(get by board) b)
  ?~(c | =(who u.c))
::
++  tie-check
  =(~(wyt in board) 9)
::
++  winning-rows
  ^-  (list (list spot))
  :~  ~[[%1 %1] [%2 %1] [%3 %1]]
      ~[[%1 %2] [%2 %2] [%3 %2]]
      ~[[%1 %3] [%2 %3] [%3 %3]]
      ~[[%1 %1] [%1 %2] [%1 %3]]
      ~[[%2 %1] [%2 %2] [%2 %3]]
      ~[[%3 %1] [%3 %2] [%3 %3]]
      ~[[%1 %3] [%2 %2] [%3 %1]]
      ~[[%1 %1] [%2 %2] [%3 %3]]
  ==
--
