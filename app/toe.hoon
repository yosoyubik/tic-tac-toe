::
::::  /hoon/toe/app
  ::
/?    310
/-    toe                                        :: models in /sur/toe/hoon
/+    sole                                       :: sole's core (state machine)
:: =,    sole
[. toe sole]                                     :: exposes namespace
::
!:                                               :: turns on stack trace
::
=>  |%
    :>  #
    :>  #  %model
    :>  #
    +|
    +=  state      $:  tabla=table
                       wom=(unit ship)
                       consol=console
                       tabla=table
                       bo=board
                       toers=(map ship player)
                       consol=console
                       flag=sole-share
                       our-toer=ship                    :: me (aka I) redundant*
                       subs=(unit bone)                 :: tracks subscription
                       game=opts                        :: game state
                       src-toer=(unit ship)             :: opponent
                       who=ship                         :: who's turn is (mutex)
                       next=?
                       reqs=requests
                    ==
    +=  move       (pair bone card)
    +=  card       $%  [%diff diff-data]
                       [%peer wire dock path]
                       [%wait wire p=@da]
                       [%pull wire dock ~]
                   ==
    +=  spot       [x=num y=num]
    +=  num        ?(%1 %2 %3)
    +=  diff-data  $?  [%turno turno]
                       [%invite player restart]
                       [%winner winner]
                       [%end ~]
                       [%sole-effect sole-effect:sole]
                   ==
    +=  console    $:  bon=bone                        :: socket for the console
                       share=sole-share:sole                :: console's state
                   ==
    :>  #
    :>  #  %constant
    :>  #
    :>  constants, in their own chapter.
    +|
    ++  welcome   txt+"TIC-TAC-TOE "
    ++  menu-1    " | player? (X/O) | "
    ++  menu-2    " | opponent? "
    ++  waiting   " | waiting for "
    ++  keep-on   " continue? (Y/N) | "
    ++  confirm   " | play with "
    ++  continue  txt+" | ready for more? (Y/N) | "
    ++  row-sep   leaf+" ---------"
    ++  texto     txt+"¡hola terricola!"
    ++  claro     clr+~                                 :: clear screen
    ++  reset     set+~                                 :: reset prompt
    ++  tong      bel+~                                 :: call to arms
    ++  barra     '/'
    --
::
::  app logic
::
|_  [bol=bowl:gall state]
::
++  prep
  :: TODO: "always reset state no matter what" is ++ prep
  |=  *
  ^-  (quip move _+>)
  :-  ~
  %=  +>.$
      toers        ~
      our-toer     our.bol
      subs         ~
      game         %1
      src-toer     ~
      bo           ~
      tabla        [%tan ~]
      next         %.n
      flag         *sole-share
  ==
::
++  wake                                                ::>  kicked by timer
  |=  [wir=wire ~]
  ^-  (quip move _+>)
  =^  edit  share.consol  (~(transmit sole share.consol) reset)
  [[(effect bon.consol det+edit)]~ +>.$]
::
::
++  poke-atom                                        :: FIXME. there shoud be
  |=  a=@                                            :: a way to reset the state
  ^-  (quip move _+>)                                :: that's not an ugly poke
  :-  :~  %+  effect
              bon.consol
              mor+[claro welcome tabla (prompt menu-1) ~]
      ==
  %=  +>.$
      toers        ~
      our-toer     our.bol
      subs         ~
      game         %1
      src-toer     ~
      bo           ~
      tabla        [%tan ~]
      reqs         ~
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
++  help
  ^-  (list sole-effect:sole)
  =-  (scan - (more (just '\0a') (stag %txt (star prn))))
  ?~  subs  "You are on!"
  """

  1 - invite ship to a game (e.g. 1: ~marzod)
  2 - start lonely game     (e.g. 2: ~)
  3 - start game and wait   (e.g. 3: ~)

  """
::
++  diff-invite                                             :: invite accepted
  |=  [wir=wire per=player ret=restart]
  ^-  (quip move _+>)
  ?~  ret                                                  :: first match
    =/  our-icon  (get-icon [~ per])
    =/  src-icon  (get-icon [~ (switch [~ per])])
    :-  :~  %+  effect
                bon.consol
                :~  %mor
                    (prompt " |{<our-toer>}:[{our-icon}] -> {<(need src-toer)>}:[{src-icon}] ")
                ==
         ==
    %=  +>.$
        game      %4
        src-toer  [~ src.bol]
        who       src.bol                                 :: opponet's turn
    ==                                                    :: subsequent matches
  ?.  next                                                :: already say yes?
    [~ +>.$(next %.y)]
  =.  bo  ~                                               :: fresh start
  =.  tabla  [%tan (flop print-board)]
  =/  our-icon  (get-icon [~ (switch [~ per])])
  =/  src-icon  (get-icon [~ per])
  :_  +>.$(game %4, who our-toer, next %.n)
  :~  %+  effect
          bon.consol
          :~  %mor
              tabla
              (prompt " |{<our-toer>}:[{our-icon}] <- {<(need src-toer)>}:[{src-icon}] ")
          ==
  ==
::
++  diff-end
  |=  [wir=wire *]
  =^  edit  share.consol  (transmit-sole reset)
  :-  %+  effect  bon.consol
          :~  %mor
              det+edit
              claro
              tabla
              (prompt menu-1)
          ==
  %=  +>.$                                             ::  Reset game state
      toers        ~
      our-toer     our.bol
      subs         ~
      game         %1
      src-toer     ~
      bo           ~
      tabla        [%tan ~]
  ==
::
++  diff-winner
  |=  [wir=wire win=winner]
  ^-  (quip move _+>)
  =^  out  bo  (step tur.win)
  =.  tabla  [%tan (flop print-board)]
  :_  +>.$(game %5)
  :~  %+  effect
          bon.consol
          mor+[tabla (prompt (weld out.win keep-on)) ~]
  ==
::
++  peer-invite
  |=  pax=path
  ^-  (quip move _+>)
  :: We receive the invitation and send waiting confirm state to sole
  ?~  subs                                                 :: game ongoing?
    :-  :~  %+  effect  bon.consol
            (prompt (weld confirm "{<src.bol>}? (Y/N) | "))
        ==
    %=  +>.$
        game      %3
        src-toer  [~ src.bol]
        subs      [~ ost.bol]
    ==
  =/  request  set+`(list @c)``(list @)``" [{<src.bol>} requests to play] "
  =^  edit  share.consol  (~(transmit sole share.consol) request)
  :_  +>.$(reqs (weld [ost.bol src.bol]~ reqs))             :: save request to play
  :~  (effect bon.consol det+edit)
      [ost.bol %wait / `@da`(add now.bol ~s3)]
  ==
::
++  peer-confirm
  |=  pax=path
  ^-  (quip move _+>)
  [~ +>.$(subs [~ ost.bol])]                              :: Diffs sent on subs
::
++  reap
  |=  [wir=wire err=(unit tang)]
  ?~  err
    [~ +>]
  :_  +>.$
  [(effect bon.consol tan+u.err) ~]
::
++  send-invite                                           :: spam who's who
  ^-  move
  [ost.bol %peer /invite [(need src-toer) dap.bol] /invite]
::
++  send-turno                                            :: spam with turno
  |=  tur=turno
  ^-  move
  [(need subs) %diff %turno tur]
::
++  send-winner                                            :: spam with winner
  |=  win=winner
  ^-  move
  [(need subs) %diff %winner win]
::
++  reject-invite
  ^-  move
  [(need subs) %pull /invite [(need src-toer) dap.bol] ~]
++  unsubscribe
  ^-  move
  [(need subs) %pull /subscribe [(need src-toer) dap.bol] ~]
++  confirm-invite
  |=  [per=player ret=restart]
  ^-  move
  [(need subs) %diff %invite per ret]
::
++  diff-turno
  |=  [wir=wire tur=turno]
  ^-  (quip move _+>)
  =^  out  bo  (step tur)                                      :: move on board
  =.  toers  (~(put by toers) our.bol (switch [~ player.tur]))
  =.  toers  (~(put by toers) src.bol player.tur)
  =.  tabla  [%tan (flop print-board)]
  =/  our-icon  (get-icon [~ (switch [~ player.tur])])
  =/  src-icon  (get-icon [~ player.tur])
  :_  +>.$(who our-toer)                                      :: now is our turn
  :~  %+  effect
          bon.consol
          :~  %mor
              tabla
              (prompt " | {<our-toer>}:[{our-icon}] <- {<(need src-toer)>}:[{src-icon}] | ")
          ==
  ==
::
++  coup                                                    :: catch poke errors
  |=  [wir=wire err=(unit tang)]
  ?~  err
    [~ +>]
  :_  +>.$
  [(effect bon.consol tan+u.err) ~]
::
:: ++  poke-invite                                       :: FIXME maybe better
  :: |=  per=player                                      :: to use poke(s)
  :: ^-  (quip move _+>)                                 :: instead of two peers
  :: :: We receive the invitation and respond if we wanna play...
  :: =.  toers  (~(put by toers) our.bol (switch [~ play]))
  :: =.  toers  (~(put by toers) src.bol play)
  :: :-  :~  %+  effect
  ::         bon.consol
  ::         (prompt (weld confirm "{<src.bol>} [Y/N] "))
  ::     ==
  :: %=  +>.$
  ::     game      %3
  ::     src-toer  [~ src.bol]
  ::     subs      [~ ost.bol]
  :: ==
::
++  effect
  |=  [bon=bone fec=sole-effect:sole]
  ^-  move
  [bon %diff %sole-effect fec]
::
++  prompt-init                                         :: game start prompt
  ^-  sole-prompt:sole
  [& %$ " select one of the options (1-3) "]
::
++  prompt                                              :: game input prompt
  |=  dial=tape
  ^-  sole-effect:sole
  pro+[& %$ dial]
::
++  peer-sole                                           :: sole subscribes to us
  |=  path
  ^-  (quip move _+>)
  =.  tabla  [%tan (flop print-board)]
  =/  output  mor+[clr+~ welcome tabla (prompt menu-1) ~]
  :: =.  soles  (~(put by soles) ost.bol *sole-share:sole)
  =.  consol  [ost.bol *sole-share:sole]
  :_  +>.$
  [(effect ost.bol output)]~
::
++  transmit-sole
  |=  inv=sole-edit:sole
  ^-  [sole-change:sole sole-share:sole]
  (~(transmit sole share.consol) inv)
::
++  toer-to-symbol
  |=  co=cord
  ^-  player
  ?:  =(co 'X')
    %x
  %o
::
++  end-message
  |=  out=outcome
  ^-  tape
  ?:(=(out %tie) " It's a tie!" " | {<who>} wins!")
::
++  game-starts
  |=  buf=sole-buffer:sole
  ^-  (quip move _+>)
  ?-    game                                           :: game state
      %1                                               :: 1: select toer (X O)
    =/  try  (rust (tufa buf) (mask "XO"))
    ?~  try
      :_  +>.$
      [(effect bon.consol txt+" toer not selected [X or O]!  ")]~
    =.  toers  (~(put by toers) our.bol (toer-to-symbol u.try))
    =^  edit  share.consol  (transmit-sole reset)
    :_  +>.$(game %2)
    :~  %+  effect
            bon.consol
            mor+[det+edit (prompt menu-2) ~]
    ==
      %2                                                :: 2: select opponent
    =/  try  (rust (tufa buf) ;~(pfix sig fed:ag))
    ?~  try
      [~ +>.$]                                          :: still waiting...
    ?.  =(src-toer ~)
      :_  +>.$
      [(effect bon.consol txt+" still waiting for {<(need src-toer)>}... ")]~
    =.  src-toer  try
    =^  edit  share.consol  (transmit-sole reset)
    :_  +>.$
    :~  send-invite
        %+  effect  bon.consol
                    :~  %mor
                        det+edit
                        (prompt (weld waiting "{(scow %p u.try)} | "))
                    ==
    ==
      %3                                                :: 3. Wait for confirm
    =/  try  (rust (tufa buf) (mask "YN"))
    ?~  try
      [~ +>.$]
    ?:  =(u.try 'N')
      [~ +>.$(game %1, src-toer ~)]                     ::  Reset game state
    ::  Game accepted
    =.  toers  (~(put by toers) our-toer %x)            :: hard-coded icons
    =.  toers  (~(put by toers) (need src-toer) %o)
    =+  our-icon=(get-icon [~ %x])
    =+  src-icon=(get-icon [~ %o])
    =^  edit  share.consol  (transmit-sole reset)
    :_  +>.$(game %4, who our-toer)                     ::  first turn
    :~  %+  effect
            bon.consol
            :~  %mor
                det+edit
                (prompt " | {<our-toer>}:[{our-icon}] <- {<(need src-toer)>}:[{src-icon}] | ")
            ==
        ^-  move
        :*  (need subs)                                 :: subscribe back
            %peer                                       :: TODO research two-way
            /subscribe                                  :: subscription model
            [(need src-toer) dap.bol]                   :: maybe with Hall?
            /confirm
        ==
        (confirm-invite [%o ~])                          :: send other's icon
    ==
      %4                                                :: 4. Moves start!
    =/  try  (rust (tufa buf) position)
    ?~  try
      [~ +>.$]
    ?.  =(our.bol who)
      :_  +>.$
      [(effect bon.consol txt+" wait for your turn ")]~
    ?:  (~(has by bo) (spot-val (need try)))
      :_  +>.$
      [(effect bon.consol txt+" Spot taken ")]~
    =/  new-step  [(~(got by toers) our-toer) (spot-val u.try)]
    =^  out  bo  (step new-step)                             :: move on board
    =/  our-icon  (get-icon (~(get by toers) our-toer))
    =/  src-icon  (get-icon (~(get by toers) (need src-toer)))
    ?~  out                                                  :: game goes on
      =.  tabla  [%tan (flop print-board)]
      =^  edit  share.consol  (transmit-sole reset)          :: update our tabla
      :_  +>.$(who (need src-toer))                          :: switch turn
      :~  (send-turno new-step)
          ^-  move
          %+  effect
              bon.consol
              :~  %mor
                  tabla
                  det+edit
                  (prompt " | {<our-toer>}:[{our-icon}] -> {<(need src-toer)>}:[{src-icon}] |")
              ==
      ==
    =.  tabla  [%tan (flop print-board)]                    :: game ends
    =^  edit  share.consol  (transmit-sole reset)           :: send winner turno
    :-  :~  (send-winner [(end-message out) new-step])
            %+  effect
                bon.consol
                :~  %mor
                    det+edit
                    tabla ::(end-message out)
                    (prompt (weld (end-message out) keep-on))
                ==
        ==
    %=  +>.$                                                   :: cleaning up
        game         %5
        bo        ~
        tabla        [%tan ~]
    ==
      %5                                                       :: reset/continue
    =/  try  (rust (tufa buf) (mask "YN"))
    ?~  try
      [~ +>.$]
    =^  edit  share.consol  (transmit-sole reset)
    ?:  =(u.try 'Y')
      =.  bo  ~
      =.  tabla  [%tan (flop print-board)]
      =/  our-icon  (get-icon (~(get by toers) our-toer))
      =/  src-icon  (get-icon (~(get by toers) (need src-toer)))
      ?:  =(next %.y)                                 :: opponent had confirmed
        :_  +>.$(game %4, who (need src-toer), next %.n)
        :~  (confirm-invite [(~(got by toers) our-toer) [~ %0]])
            %+  effect
                bon.consol
                :~  %mor
                    tabla
                    det+edit
                    (prompt " | {<our-toer>}:[{our-icon}] -> {<(need src-toer)>}:[{src-icon}] | ")
                ==
        ==
      :_  +>.$(game %5, next %.y)
      :~  (confirm-invite [(~(got by toers) our-toer) [~ %0]])
          %+  effect
              bon.consol
              :~  %mor
                  det+edit
                  (prompt " | ...waiting for {<(need src-toer)>}'s approval |")
              ==
      ==
    ?~  reqs                                             :: any request to play?
      =.  bo  ~
      =.  tabla  [%tan (flop print-board)]
      :-  :~  reject-invite                              :: disconnect
              unsubscribe
              %+  effect  bon.consol
                  :~  %mor
                      det+edit
                      claro
                      tabla
                      (prompt menu-1)
                  ==
          ==
      %=  +>.$                                            ::  Reset game state
          toers        ~
          our-toer     our.bol
          subs         ~
          game         %1
          src-toer     ~
          bo           ~
          tabla        [%tan ~]
      ==
    =/  invite  +:(snag 0 ^-(requests reqs))              :: funky snag behavior
    :-  :~  %+  effect
                bon.consol
                :~  %mor
                    det+edit
                    (prompt (weld confirm "{<invite>} (Y/N) | "))
                ==
        ==
    %=  +>.$
        game      %3
        src-toer  [~ invite]
        subs      [~ -:(snag 0 ^-(requests reqs))]
        bo         ~
        tabla     [%tan ~]
    ==
  ==
::
++  poke-sole-action
  |=  act=sole-action:sole
  ^-  (quip move _+>)
  =/  solate  share.consol
  ?-    -.act
      $clr  [~ +>.$]                                           :: clear screen
      $ret                                                     :: enter
    ?~  buf.solate
      [~ +>.$]
    (game-starts buf.solate)                                   :: start game
        $det                                                   :: key press
      =^  inv  share.consol  (~(transceive sole solate) +.act) :: edit&new share
      [~ +>.$]
    ==
::
++  num-rule  (shim '1' '3')
++  indice    (cook |=(a/@ (sub a '0')) num-rule)
++  position  ;~((glue fas) indice indice)           :: [1-3]/[1-3]
::
++  spot-val
  |=  a=[@ @]
  ?>(?=(spot a) a) :: If assertion is true, return the input. model validation
::
++  player-pos
  |=  [ro=@ co=@]  ^-  tape
  =+  per=(~(get by bo) [ro co])
  (get-icon per)
::
++  print-row
  |=  ro=@  ^-  row
  =/  co  1
  :-  %leaf
  %-  zing
  |-
  =/  per  (player-pos [ro co])
  ?:  ?&(=(%4 co))
    ~
  :-
    ?:  ?&(=(co %1))
      (weld (weld " " per) " ")
    ?:  ?&(=(co %2))
      (weld (weld "| " per) " ")
    ?:  ?&(=(co %3))
      (weld (weld "| " per) " ")
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
  ^-  [outcome board]
  =.  bo  (~(put by bo) [spot.tur player.tur])
  [(outcome-check player.tur) bo]
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
  %+  lien  winning-rows
  |=  a=(list spot)
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
