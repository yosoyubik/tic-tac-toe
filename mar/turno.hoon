::
::::  /hoon/noun/mar
  ::
/?    310
!:
=>  |%
      +=  turno  [=player =spot]
      +=  player  ?(%x %o ~)
      +=  spot  [x=num y=num]
      +=  num  ?(%1 %2 %3)
    --
::::  A minimal turno mark
|_  turno
++  grab  |%
          ++  noun  turno
          --
--
