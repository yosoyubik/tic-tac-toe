/?    310
::
::  Queue that handles incoming/outgoing subscriptions
::
|%
++  cola
  ::  %a: is our sample and our cola operates on it
  ::
  =|  a=(tree)
  ::  Our cola is a wet core, the arms use genericity
  ::
  |@
  ++  bal
    |-  ^+  a
    ?~  a  ~
    ?.  |(?=(~ l.a) (mor n.a n.l.a))
      $(a [n.l.a l.l.a $(a [n.a r.l.a r.a])])
    ?.  |(?=(~ r.a) (mor n.a n.r.a))
      $(a [n.r.a $(a [n.a l.a l.r.a]) r.r.a])
    a
  ::
  ++  dep                                               ::  max depth of queue
    |-  ^-  @
    ?~  a  0
    +((max $(a l.a) $(a r.a)))
  ::
  ++  gas                                               ::  insert list to que
    |=  b/(list _?>(?=(^ a) n.a))
    |-  ^+  a
    ?~(b a $(b t.b, a (put i.b)))
  ::
  ++  get                                               ::  head-rest pair
    |-  ^+  ?>(?=(^ a) [p=n.a q=*(tree _n.a)])
    ?~  a
      !!
    ?~  r.a
      [n.a l.a]
    =+  b=$(a r.a)
    :-  p.b
    ?:  |(?=(~ q.b) (mor n.a n.q.b))
      [n.a l.a q.b]
    [n.q.b [n.a l.a l.q.b] r.q.b]
  ::
  ++  nip                                               ::  remove root
    |-  ^+  a
    ?~  a  ~
    ?~  l.a  r.a
    ?~  r.a  l.a
    ?:  (mor n.l.a n.r.a)
      [n.l.a l.l.a $(l.a r.l.a)]
    [n.r.a $(r.a l.r.a) r.r.a]
  ::
  ++  nap                                               ::  removes head
    ?>  ?=(^ a)
    ?~  a  ~
    =+  b=get
    ?~  q.b  ~
    bal(a ^+(a [n=n.q.b l=l.q.b r=r.q.b]))
  ::
  ++  put                                               ::  insert new tail
    |*  b/*
    |-  ^+  a
    ?~  a
      [b ~ ~]
    bal(a a(l $(a l.a)))
  ::
  ++  tap                                               ::  adds list to end
    =+  b=`(list _?>(?=(^ a) n.a))`~
    |-  ^+  b
    =+  0                                               ::  hack for jet match
    ?~  a
      b
    $(a r.a, b [n.a $(a l.a)])
  ::
  ++  top                                               ::  produces head
    |-  ^-  (unit _?>(?=(^ a) n.a))
    ?~  a  ~
    ?~(r.a [~ n.a] $(a r.a))
  --
--
