runoncepath("0:TrPre.ks").

clearscreen.
local p1 to processor("main").
local c1 to p1:Connection.

core:Messages:clear().

until not core:Messages:empty{
  wait 0.001.
}

core:Messages:clear().

lock isend to false.

when not core:Messages:empty then {
  until core:Messages:empty{
    set msg to core:Messages:pop.
    set str to msg:content.
  }
  if str = "end"{
    set isend to true.
  }
  return true.
}
local X to Trpre().
local Y to X.
local t0 to time:seconds.
local t1 to time:seconds.
local dt to t1-t0.
local T to 0.5.
until false {
  set X to Trpre().
  set t1 to time:seconds.
  set dt to t1-t0.
  set t0 to t1.
  set Y to latlng(Y:lat*(1-dt/T) + X:lat*(dt/T), Y:lng*(1-dT/T) + X:lng*(dt/T)).
  print X at (0,6).
  print Y at (0,8).
  c1:SendMessage(X).
  if isend = true{
    break.
  }
  wait 0.001.
}
