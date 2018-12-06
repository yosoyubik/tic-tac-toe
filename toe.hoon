::
::
::
/?    310
/+  sole, prey
:: !:
[. sole]
=>  |%
    :>  #
    :>  #  %model
    :>  #
    +|
    +=  state
      $:  tabla=table
          wom=(unit ship)
          consol=console
          tabla=table
          board=(map spot player)
          toers=(map ship player)
          our-toer=ship                                :: me (aka I)
          subs=(unit bone)                             :: tracks subscriptions
          game=opts
          src-toer=(unit ship)                         :: opponent
          who=ship                                     :: who's turn is (mutex)
      ==
    +=  console  [bon=bone share=sole-share]
    +=  move  (pair bone card)
    +=  card  $%  [%diff %sole-effect sole-effect]
                  [%diff diff-data]
                  [%wait wire p=@da]
                  [%peer wire dock path]
                  [%poke wire dock poke-data]
              ==
    +=  poke-data  $?  [%invite player]
                   ==
    +=  diff-data  $?  [%turno turno]
                       [%invite player]
                       [%winner [%txt tape]]
                   ==
    +=  action  $%  [%sub @p]                      ::  subscribe to a game on @p
                    [%disc ~]                      ::  disconnect from a game
                ==
    +=  table   [%tan rows=(list row)]
    +=  row     [%leaf tape]
    +=  outcome  ?(%wins %tie ~)
    +=  turno  [=player =spot]
    +=  player  ?(%x %o ~)
    +=  spot  [x=num y=num]
    +=  num  ?(%1 %2 %3)
    +=  opts  ?(%1 %2 %3 %4)
    :>  #
    :>  #  %constant
    :>  #
    :>  constants, in their own chapter.
    +|
    ++  welcome   txt+" Welcome to TIC-TAC-TOE "
    ++  menu-1    " What TOEr do you want to be? [X O] "
    ++  menu-2    " Who do you wanna play with? [eg. ~tipnyx-ramsug] "
    ++  waiting   " ...waiting for "
    ++  confirm   " Do you want to play a game with: "
    ++  row-sep   leaf+" ---------"
    ++  texto     txt+"¡hola terricola!"
    ++  claro     clr+~
    ++  tong      bel+~
    ++  barra     '/'
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
  :-  ~
  %=  +>.$
    toers        ~
    our-toer     our.bol
    subs         ~
    game         %1
    src-toer     ~
    board        ~
    tabla        [%tan ~]
  ==
::
++  poke-atom                                        :: FIXME. there shoud be
  |=  a=@                                            :: a way to reset the state
  ^-  (quip move _+>)
  =/  output  mor+[clr+~ txt+" reset state..." welcome tabla (prompt menu-1) ~]
  :-  [(effect bon.consol output)]~
  %=  +>.$
    toers        ~
    our-toer     our.bol
    subs         ~
    game         %1
    src-toer     ~
    board        ~
    tabla        [%tan ~]
  ==
::
++  wake                                                ::>  kicked by timer
  |=  [wir=wire ~]
  ^-  (quip move _+>)
  [~ +>.$]
::
++  switch
  |=  toer=(unit player)
  ^-  player
  ?~  toer  ~
  ?:(=(u.toer %o) %x %o)
::
++  get-icon
  |=  per=(unit player)
  ^-  tape
  ?~  per
    " "
  (cuss (scow %tas u.per))
::
++  help
  ^-  (list sole-effect)
  =-  (scan - (more (just '\0a') (stag %txt (star prn))))
  ?~  subs  "You are on!"
  """

  1 - invite ship to a game (e.g. 1: ~marzod)
  2 - start lonely game     (e.g. 2: ~)
  3 - start game and wait   (e.g. 3: ~)

  """
::
++  diff-invite                                  :: invite accepted
  |=  [wir=wire play=player]
  ^-  (quip move _+>)
  =.  toers     (~(put by toers) [our.bol play])
  =.  toers     (~(put by toers) [src.bol (switch [~ play])])
  =/  log       " {<src.bol>} has accepted your invite! "
  =/  our-icon  (get-icon [~ play])
  :-  :~  %+  effect
              bon.consol
              :~  %mor
                  txt+log
                  (prompt " player: {<our-toer>} [{our-icon}] (row/col): ")
              ==
  ==
  %=  +>.$
      game      %4
      src-toer  [~ src.bol]
      who       src.bol
  ==
::
++  diff-winner
  |=  [wir=wire outcome=[%txt tape]]
  ^-  (quip move _+>)
  =.  tabla  [%tan ~]
  =/  output  mor+[outcome welcome tabla (prompt menu-1) ~]
  :-  [(effect bon.consol output)]~
  %=  +>.$
    toers        ~
    our-toer     our.bol
    subs         ~
    game         %1
    src-toer     ~
    board        ~
  ==
::
::
++  peer-invite
  |=  pax=path
  ^-  (quip move _+>)
  :: We receive the invitation and send waiting confirm state to sole
  :-  :~  %+  effect
              bon.consol
              (prompt (weld confirm "{<src.bol>} [Y/N] "))
      ==
  %=  +>.$
      game      %3
      src-toer  [~ src.bol]
      subs      [~ ost.bol]                               :: Diffs sent on subs
  ==
::
++  peer-confirm
  |=  pax=path
  ^-  (quip move _+>)
  [~ +>.$(subs [~ ost.bol])]                              :: Diffs sent on subs
::
++  reap                                    :: Check is sub is ok
  |=  [wir=wire err=(unit tang)]
  ?~  err
    [~ +>]
  :_  +>.$
  [(effect bon.consol tan+u.err) ~]
::
++  send-invite                                :: spam subscriber with who's who
  ^-  move
  [ost.bol %peer /invite [(need src-toer) %toe] /invite]
::
++  send-turno                                 :: spam subscriber with turno
  |=  tur=turno
  ^-  move
  [(need subs) %diff %turno tur]
::
++  send-winner                                 :: spam subscriber with winner
  |=  win=[%txt tape]
  ^-  move
  [(need subs) %diff %winner win]
::
++  diff-turno
  |=  [wir=wire tur=turno]
  ^-  (quip move _+>)
  =^  out  board  (step tur)                     :: move on board
  =.  tabla  [%tan (flop print-board)]
  :_  +>.$(who our-toer)                         :: now is our turn
  [(effect bon.consol tabla)]~
::
++  coup-invite
  |=  [wir=wire err=(unit tang)]
  ?~  err
    [~ +>]
  :_  +>.$
  [(effect bon.consol tan+u.err) ~]
::
++  poke-invite
  |=  play=player
  ^-  (quip move _+>)
  :: We receive the invitation and respond if we wanna play...
  =.  toers  (~(put by toers) our.bol (switch [~ play]))
  =.  toers  (~(put by toers) src.bol play)
  :-  :~  %+  effect
          bon.consol
          (prompt (weld confirm "{<src.bol>} [Y/N] "))
      ==
  %=  +>.$
      game      %3
      src-toer  [~ src.bol]
      subs      [~ ost.bol]
  ==
::
++  effect
  |=  [bon=bone fec=sole-effect]
  ^-  move
  [bon %diff %sole-effect fec]
::
++  prompt-init                                        :: game start prompt
  ^-  sole-prompt
  [& %$ " select one of the options (1-3) "]
::
++  prompt                                             :: game input prompt
  |=  dialog=tape
  ^-  sole-effect
  pro+[& %$ dialog]
::
++  peer-sole                                          :: sole subscribes to us
  |=  path
  ^-  (quip move _+>)
  =.  tabla  [%tan (flop print-board)]
  =/  output  mor+[clr+~ welcome tabla (prompt menu-1) ~]
  :_  +>.$(consol [ost.bol *sole-share])
  [(effect ost.bol output)]~
::
++  toer-to-symbol
  |=  co=cord
  ^-  player
  ?:  =(co 'X')
    %x
  %o
::
++  game-starts
  |=  buff=sole-buffer
  ^-  (quip move _+>)
  ?-    game                                           :: game state
      %1                                               :: 1: select toer (X O)
    =/  try  (rust (tufa buff) (mask "XO"))
    ?~  try
      :_  +>.$
      [(effect bon.consol txt+" toer not selected [X or O]!  ")]~
    =.  toers  (~(put by toers) our.bol (toer-to-symbol u.try))
    :_  +>.$(game %2)
    :~  %+  effect
            bon.consol
            mor+[txt+" your TOEr is going to be: {<u.try>} " (prompt menu-2) ~]
    ==
      %2                                                :: 2: select opponent
    =/  try  (rust (tufa buff) ;~(pfix sig fed:ag))
    ?~  try
      ?~  src-toer
        :_  +>.$
        :~  %+  effect
                bon.consol
                txt+" {(tufa buff)} is not a valid opponent...  "
        ==
      [~ +>.$]                                               :: still waiting...
    =.  src-toer  try
    :_  +>.$
    :~  send-invite
        %+  effect  bon.consol
                    :~  %mor
                        txt+(weld waiting "{(scow %p u.try)}")
                        (prompt "    ...     ")
                    ==
    ==
      %3                                                :: 3. Wait for confirm
    =/  try  (rust (tufa buff) (mask "YN"))
    ?~  try
      [~ +>.$]
    ?:  =(u.try 'N')
      [~ +>.$(game %1, src-toer ~)]                     ::  Reset game state
    ::  Game accepted
    =.  toers  (~(put by toers) our-toer %x)            :: hard-coded icons
    =.  toers  (~(put by toers) (need src-toer) %o)     ::
    =+  our-icon=(get-icon [~ %x])
    :_  +>.$(game %4, who our-toer)                     ::  first turn
    :~  %+  effect
            bon.consol
            (prompt " player: {<our-toer>} [{our-icon}] (row/col): ")
        ^-  move
        :*  (need subs)                                 :: subscribe back
            %peer
            /subscribe
            [(need src-toer) %toe]
            /confirm
        ==
        [(need subs) %diff %invite %o]                  :: send other's icon
    ==
      %4                                                :: 4. Moves start!
    =/  try  (rust (tufa buff) position)
    ?~  try
      [~ +>.$]
    ?.  =(our.bol who)
      :_  +>.$
      [(effect bon.consol txt+" wait for your turn ")]~
    =/  spo  (spot-val u.try)
    =/  our-icon  (get-icon (~(get by toers) our-toer))
    ?:  (~(has by board) spo)
      :_  +>.$
      [(effect bon.consol txt+" Spot taken ")]~
    =/  new-step  [(~(got by toers) our-toer) spo]
    =^  out  board  (step new-step)                       :: put move on board
    ?~  out                                                   :: game goes on
      =.  tabla  [%tan (flop print-board)]                  :: update our tabla
      :_  +>.$(who (need src-toer))                         :: switch turn
      :~  (send-turno new-step)
          ^-  move
          %+  effect
              bon.consol
              :~  %mor
                  tabla
                  (prompt " player: {<our-toer>} [{our-icon}] (row/col): ")
              ==
      ==
    =/  outcome  :-  %txt
    %+  weld  " End game:  "
    ?:(=(out %tie) "it's a tie" (weld (scow %p who) " wins!"))
    =.  tabla  [%tan ~]                                       :: cleaning up
    =/  output  mor+[outcome welcome tabla (prompt menu-1) ~]
    :-  :~  (send-winner outcome)
            (effect bon.consol output)
        ==
    %=  +>.$
      toers        ~
      our-toer     our.bol
      subs         ~
      game         %1
      src-toer     ~
      board        ~
    ==
  ==
::
++  poke-sole-action
  |=  act=sole-action
  ^-  (quip move _+>)
  :: =/  som  (~(got by soles) ost.bol)
  =/  som  share.consol
  ?-    -.act
      $clr  [~ +>.$]                                          :: clear screen
      $ret                                                    :: enter
    ?~  buf.som
      [~ +>.$]
    (game-starts buf.som)                                     :: start game
        $det                                                  :: key press
      =^  inv  som  (~(transceive sole som) +.act)            :: new edit & inv?
      :: =.  soles  (~(put by soles) ost.bol som)             :: accumulate edit
      =.  consol  [ost.bol som]
      [~ +>.$]
    ==
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
:: ++  poke-sole-action
::   |=  act=sole-action
::   ^-  (quip move _+>)
::   =/  som  (~(got by soles) ost.bol)
::   ?-    -.act
::       $clr  [~ +>.$]                                           :: clear screen
::       $ret                                                     :: enter
::     ?~  game
::       :_  +>.$
::       [(effect txt+" game option not selected!  ")]~
::     ?:  =(~ buf.som)
::       :_  +>.$
::       [(effect txt+"enter position for '{our-toer}' (e.g. 1/1)  ")]~
::     =/  try  (rust (tufa buf.som) position)
::     ?~  try
::       [~ +>.$]
::     =/  spo  (spot-val u.try)
::     ?:  (~(has by board) spo)
::       :_  +>.$
::       [(effect txt+" Spot taken ")]~
::     =^  out  board  (step [toer spo])
::     ?:  =(game %2)
::       =.  toer  switch                                        :: auto switch player
::     ::  toer is switch by subscription update
::     =.  tabla  [%tan (flop print-board)]
::     ?~  out                                                   :: game goes on
::       :_  +>.$
::       =+  [tabla ~]  [(effect %mor pro+prompt -)]~
::     =/  outcome  :-  %txt
::     %+  weld  " End game:  "
::     ?:(=(out %tie) "it's a tie" (weld last-toer " wins!"))
::     :_  +>.$(board *(map spot player))                        :: cleaning up
::     =-  [(effect %mor outcome -)]~
::     [pro+prompt tabla ~]
::       $det                                                    :: key press
::     =^  inv  som  (~(transceive sole som) +.act)              :: new edit & inv?
::     =.  soles  (~(put by soles) ost.bol som)                  :: accumulate edit
::     [~ +>.$]
::   ==
::
++  player-pos
  |=  [ro=@ co=@]  ^-  tape
  =+  player=(~(get by board) [ro co])
  (get-icon player)
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
  |=  tur=turno
  ^-  [outcome (map spot player)]
  =.  board  (~(put by board) [spot.tur player.tur])
  [(outcome-check player.tur) board]
::
++  outcome-check
  |=  play=player
  ^-  outcome
  ?:  (win-check play)
    %wins
  ?:(tie-check %tie ~)
::
++  win-check
  |=  play=player
  %+  lien  winning-rows
  |=  a=(list spot)
  %+  levy  a
  |=  b=spot
  =/  c=(unit player)  (~(get by board) b)
  ?~(c | =(play u.c))
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
