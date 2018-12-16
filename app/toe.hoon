::
::::  /hoon/toe/app
  ::
/?    310
/-    toe                                                 :: models
/+    sole                                                :: console lib
[. toe sole]                                              :: exposes namespace
::
!:                                                        :: stack trace on
::
=>  |%
    :>  #
    :>  #  %models
    :>  #
    +|
    +=  state      $:  tabla=table                        :: board on screen
                       consol=console                     :: sole-share
                       bo=board                           :: internal board
                       toers=(map ship player)            :: who's who
                       me=ship                            :: me (aka I)
                       game=opts                          :: game state
                       who=ship                           :: who's turn (mutex)
                       next=?                             :: keep playing?
                       opos=subs                          :: subscription queue  TODO: explore if gall has this
                    ==
    +=  move       (pair bone card)
    +=  spot       [num num]                              :: has to be redefined FIXME: ?!? wtf! ist' already in sur...
    +=  card       $%  [%diff diff-data]
                       [%peer wire dock path]
                       [%pull wire dock ~]
                   ==
    +=  diff-data  $?  [%toe-turno toe-turno]
                       [%toe-player message player]
                       [%toe-winner toe-winner]
                       [%sole-effect sole-effect:sole]
                   ==
    +=  console    $:  bon=bone                           :: socket (kinda?)
                       sha=sole-share:sole                :: console's state
                   ==
    :>  #
    :>  #  %constants
    :>  #
    +|
    ++  welcome   txt+"TIC-TAC-TOE "
    ++  menu-1    " | opponent? "
    ++  waiting   " | waiting for "
    ++  abor      "(!=quit)"
    ++  keep-on   " continue? (Y/N) | "
    ++  confirm   " | play with "
    ++  continue  txt+" | ready for more? (Y/N) | "
    ++  row-sep   leaf+" ---------"
    ++  claro     clr+~                                   :: clear screen
    ++  reset     set+~                                   :: reset prompt
    ++  tong      bel+~                                   :: call to arms
    --
::
::  app logic
::
|_  [bol=bowl:gall state]
::
++  this  .
::
++  prep
  |=  *
  ^-  (quip move _+>)
  (wipe ~)
::
++  wipe
  |=  m=(list move)
  ^-  (quip move _+>)
  :-  m
  %=  +>
      opos   ~
      toers  ~
      bo     ~
      game   %1
      next   %.n
      me     our.bol
      tabla  [%tan ~]
  ==
::
++  poke-atom                                        :: FIXME. there shoud be
  |=  a=@                                            :: a way to reset the state
  ^-  (quip move _+>)                                :: that's not an ugly poke
  :-  ~[(effect mor+~[claro welcome tabla (prompt menu-1)])]
  %=  +>.$
      toers  ~
      opos   ~
      bo     ~
      game   %1
      me     our.bol
      tabla  [%tan ~]
  ==
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
  ?~  per  " "
  (cuss (scow %tas u.per))
::
++  diff-toe-player                                         :: invite accepted
  |=  [wir=wire msg=message per=player]
  ^-  (quip move _+>)
  =/  icon  (get-icons per)
  ?-    msg
      %accept                                               :: first match
    :_  +>.$(game %3, who src.bol)
    ~[(effect (prompt " | {<me>}:[{-:icon}] -> {<src.bol>}:[{+:icon}] "))]
      %rematch
    ?.  next                                                :: already said yes?
      [~ +>.$(next %.y)]
    =.  bo  ~                                               :: fresh start
    =.  tabla  print-board
    =/  guest  (need ~(top to opos))
    :_  +>.$(game %3, who me, next %.n)
    :_  ~
    %-  effect
    :~  %mor
        tabla
        (prompt " | {<me>}:[{+:icon}] <- {<ze.guest>}:[{-:icon}] ")
    ==
  ==
::
++  send-message
  |=  [msg=message per=player]
  ^-  move
  =/  guest  (need ~(top to opos))
  [bo.guest %diff %toe-player msg per]
::
++  peer-invite
  |=  pax=path
  ^-  (quip move _+>)
  =.  opos  (~(put to opos) [| ost.bol /invite src.bol])       :: enqueue
  ?~  ~(nap to opos)                                           :: 1 req in queue
    :_  +>(game %2)
    ~[(effect (prompt (weld confirm "{<src.bol>}? (Y/N) | ")))]
  :_  +>
  ~[(effect txt+" [{<src.bol>} wants to play] ")]
::
++  send-invite
  |=  ze=ship
  ^-  move
  [ost.bol %peer /invite [ze dap.bol] /invite]
::
++  peer-back                                            :: received from
  |=  pax=path                                           :: ++  subscribe-back
  ^-  (quip move _+>)
  [~ +>(opos (~(put to opos) [& ost.bol /back src.bol]))]
::
++  subscribe-back
    ^-  move
    =/  guest  (need ~(top to opos))
    =/  up-opo  [& bo.guest /invite ze.guest]           :: subs confirmed
    =.  opos   (~(put to ~(nap to opos)) up-opo)
    :*  bo.guest
        %peer                                           :: |TODO: research 2-way
        /back                                           :: |subscription model.
        [ze.guest dap.bol]                              :: |maybe with Hall?
        /back
    ==
::
:: ++  diff-end
::   |=  [wir=wire *]
::   =^  edit  sha.consol  (transmit-sole reset)
::   (wipe ~[(effect mor+~[det+edit claro tabla (prompt menu-1)])])
::
++  diff-toe-winner
  |=  [wir=wire win=toe-winner]
  ^-  (quip move _+>)
  =^  out  bo  (step tur.win)                              :: show winner move
  =.  tabla  print-board
  :_  +>.$(game %4)
  ~[(effect mor+~[tabla (prompt (weld out.win keep-on))])]
::
++  send-winner                                            :: spam with winner
  |=  win=toe-winner
  ^-  move
  =/  guest  (need ~(top to opos))
  [bo.guest %diff %toe-winner win]
::
++  send-turno                                            :: spam with turno
  |=  tur=toe-turno
  ^-  move
  =/  guest  (need ~(top to opos))
  [bo.guest %diff %toe-turno tur]
::
++  diff-toe-turno
  |=  [wir=wire tur=toe-turno]
  ^-  (quip move _+>.$)
  =^  out  bo  (step tur)                                      :: move on board
  =.  toers  (~(put by toers) our.bol (switch [~ per.tur]))
  =.  toers  (~(put by toers) [src.bol per.tur])
  =.  tabla  print-board
  =/  icon   (get-icons per.tur)
  =/  guest  (need ~(top to opos))
  :_  +>.$(who me)                                           :: now is our turn
  :_  ~
  %-  effect
  :~  %mor
      tabla
      (prompt " | {<me>}:[{+:icon}] <- {<ze.guest>}:[{-:icon}] | ")
  ==
::
++  unsubscribe
  ^-  move
  =/  guest  (need ~(top to opos))
  [bo.guest %pull wir.guest [ze.guest dap.bol] ~]
::
++  pull-invite
  |=  wir=wire
  [~ +>]
::
++  pull-back
  |=  wir=wire
  [~ +>]
::
++  reap
  |=  [wir=wire err=(unit tang)]
  ?~  err
    [~ +>]
  :_  +>.$
  [(effect tan+u.err) ~]
::
++  coup
  |=  [wir=wire err=(unit tang)]
  ?~  err
    [~ +>]
  :_  +>.$
  [(effect tan+u.err)]~
::
++  effect
  |=  fec=sole-effect:sole
  ^-  move
  [bon.consol %diff %sole-effect fec]
::
++  peer-sole                                           :: sole subscribes to us
  |=  path
  ^-  (quip move _+>)
  =.  tabla  print-board
  =/  output  mor+~[claro welcome tabla (prompt menu-1)]
  =.  consol  [ost.bol *sole-share:sole]
  :_  +>.$
  ~[(effect output)]
::
++  transmit-sole
  |=  inv=sole-edit
  ^-  [sole-change sole-share]
  (~(transmit sole sha.consol) inv)
::
++  prompt                                              :: game input prompt
  |=  dial=tape
  ^-  sole-effect:sole
  pro+[& %$ dial]
::
++  toer-to-symbol
  |=  co=cord
  ^-  player
  ?:  =(co 'X')
    %x
  ?:  =(co 'O')
    %o
  ~
::
++  end-message
  |=  out=outcome
  ^-  tape
  ?:(=(out %tie) " It's a tie!" " | {<who>} wins!")
::
++  get-icons
  |=  per=player
  [(get-icon [~ per]) (get-icon [~ (switch [~ per])])]
::
++  game-engine                                        :: TODO: make as a door?
  |=  buf=sole-buffer:sole
  ^-  (quip move _+>)
  =/  try  (rust (tufa buf) ;~(just zap))
  ?.  =(~ try)
    check-subscriptions
  ?-    game
      %1                                                :: G1: select opponent
    =/  try  (rust (tufa buf) ;~(pfix sig fed:ag))
    ?~  try
      [~ +>.$]
    =^  edit  sha.consol  (transmit-sole reset)
    =/  up-prompt  (prompt (weld waiting "{(scow %p u.try)} {abor} | "))
    :_  +>.$
    :~  (send-invite u.try)
        (effect mor+~[det+edit up-prompt])
    ==
      %2                                                :: G2. Wait for confirm
    =/  try  (rust (tufa buf) (mask "YN"))
    ?~  try
      [~ +>.$]
    ?:  =(u.try 'N')
      check-subscriptions
    =/  opo  (need ~(top to opos))                       :: 1st incoming sub
    =.  toers  (~(put by toers) me %x)                   :: Game accepted  me=X
    =.  toers  (~(put by toers) ze.opo %o)               ::                ze=O
    =/  icons  (get-icons %x)
    =^  edit  sha.consol  (transmit-sole reset)          :: clean up prompt
    :_  +>.$(game %3, who me)                            :: me= first turn
    :~  subscribe-back
        (send-message [%accept %o])
        %-  effect
        :~  %mor
            det+edit
            (prompt " | {<me>}:[{-:icons}] <- {<ze.opo>}:[{+:icons}] | ")
        ==
    ==
      %3                                                  :: G3. Moves start!
    =/  try  (rust (tufa buf) position)
    ?~  try
      [~ +>.$]
    ?.   =(our.bol who)
      :_  +>.$
      [(effect txt+" wait for your turn ")]~
    ?:  (~(has by bo) (spot-val (need try)))
      :_  +>.$
      [(effect txt+" Spot taken ")]~
    =/  new-step  [(~(got by toers) me) (spot-val u.try)]
    =^  out  bo  (step new-step)                                :: move on board
    =/  icon  (get-icons (~(got by toers) me))
    =.  tabla  print-board
    =^  edit  sha.consol  (transmit-sole reset)
    ?~  out                                                     :: game goes on
      =/  opo  (need ~(top to opos))
      :_  +>.$(who ze.opo)                                      :: switch turn
      :~  (send-turno new-step)
          %-  effect
          :~  %mor
              tabla
              det+edit
              (prompt " | {<me>}:[{-:icon}] -> {<ze.opo>}:[{+:icon}] | ")
          ==
      ==
    :_  +>.$(bo ~, game %4, tabla [%tan ~])                 :: game ends
    :~  (send-winner [(end-message out) new-step])
        %-  effect
        :~  %mor
            det+edit
            tabla
            (prompt (weld (end-message out) keep-on))
        ==
    ==
      %4                                                    :: G4: end/continue?
    =/  try  (rust (tufa buf) (mask "YN"))
    ?~  try
      [~ +>.$]
    ?:  =(u.try 'N')
      check-subscriptions
    =^  edit  sha.consol  (transmit-sole reset)
    =.  bo  ~
    =.  tabla  print-board
    =/  icon  (get-icons (~(got by toers) me))
    =/  opo  (need ~(top to opos))
    =/  rematch  (send-message [%rematch (~(got by toers) me)])
    ?:  =(next %.y)                                      :: ze already confirmed
      :_  +>.$(game %3, who ze.opo, next %.n)
      :~  rematch
          %-  effect
          :~  %mor
              tabla
              det+edit
              (prompt " | {<me>}:[{-:icon}] -> {<ze.opo>}:[{+:icon}] | ")
          ==
      ==
    :_  +>.$(game %4, next %.y)
    :~  rematch
        %-  effect
        :~  %mor
            det+edit
            (prompt " | ...waiting for {<ze.opo>}'s approval {abor} |")
        ==
    ==
  ==
::
++  check-subscriptions
  ^-  (quip move _this)
  ?:  |(?=(~ opos) ?=(~ ~(nap to opos)))                 :: one or no subs
    restart-game
  =/  opo  (need ~(top to ~(nap to opos)))               :: always unqueue head
  =^  edit   sha.consol  (transmit-sole reset)
  :-  :~  unsubscribe
          %-  effect
          :~  %mor
              det+edit
              (prompt (weld confirm "{<ze.opo>} (Y/N)? | "))
          ==
      ==
  %=  this
      bo     ~
      game   %2
      tabla  [%tan ~]
      opos   ~(nap to opos)                               :: dequeue
  ==
::
++  restart-game
  ^-  (quip move _this)
  =.  bo  ~
  =.  tabla  print-board
  =^  edit  sha.consol  (transmit-sole reset)
  =/  fect  (effect mor+~[det+edit claro tabla (prompt menu-1)])
  %-  wipe
  :*  fect
      ?~  opos  ~
      [unsubscribe ~]
  ==
::
++  poke-sole-action
  |=  act=sole-action:sole
  ^-  (quip move _+>)
  =/  solate  sha.consol
  ?-    -.act
      $clr  [~ +>.$]                                           :: clear screen
      $ret                                                     :: enter
    ?~  buf.solate
      [~ +>.$]
    (game-engine buf.solate)
        $det                                                   :: key press
      =^  inv  sha.consol  (~(transceive sole solate) +.act)   :: edit+new state
      [~ +>.$]
    ==
::
++  num-rule  (shim '1' '3')
++  indice    (cook |=(a/@ (sub a '0')) num-rule)
++  position  ;~((glue fas) indice indice)                :: e.g. [1-3]/[1-3]
::
++  spot-val                                              :: mold validation
  |=  a=[@ @]
  ?>(?=(spot a) a)
::
++  player-pos
  |=  [ro=@ co=@]
  ^-  tape
  =+  per=(~(get by bo) [ro co])
  (get-icon per)
::
++  print-row
  |=  ro=@
  ^-  row
  =/  co  1
  :-  %leaf
  %-  zing
  |-
  =/  per  (player-pos [ro co])
  ?:  ?&(=(%4 co))
    ~
  :-  ?:  ?&(=(co %1))
        (weld (weld " " per) " ")
      ?:  ?&(=(co %2))
        (weld (weld "| " per) " ")
      ?:  ?&(=(co %3))
        (weld (weld "| " per) " ")
      ~
  $(co (add co 1))
::
++  print-board
  |-  ^-  [%tan (list row)]
  =/  ro  1
  :-  %tan
  %-  flop
  |-
  ?:  =(ro 4)
    [leaf+"" ~]
  ?:  ?&(=(ro 3))
    [(print-row ro) $(ro (add ro 1))]
  [(print-row ro) row-sep $(ro (add ro 1))]
::
++  step
  |=  tur=toe-turno
  ^-  [outcome board]
  =.  bo  (~(put by bo) [spo.tur per.tur])
  [(outcome-check per.tur) bo]
::
++  outcome-check
  |=  per=player
  ^-  outcome
  ?:  (win-check per)
    %wins
  ?:(tie-check %tie ~)
::
++  win-check
  |=  per=player
  ^-  ?
  %+  lien  winning-rows
  |=  a=(list spot)
  ^-  ?
  %+  levy  a
  |=  b=spot
  =/  c=(unit player)  (~(get by bo) b)
  ?~(c | =(per u.c))
::
++  tie-check
  =(~(wyt in bo) 9)
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
