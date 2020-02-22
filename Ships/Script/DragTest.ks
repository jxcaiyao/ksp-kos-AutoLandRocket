clearscreen.
ag9 off.
print "按9开始着陆程序".
wait until ag9.
print "开始".

core:Messages:clear().
processor("impact"):Connection:SendMessage("begin").
until not core:Messages:empty{
  wait 0.001.
}

set file to "trajectorytest10.csv".
log "海拔高度,垂直速度,水平速度,预测落点纬度,预测落点经度" to file.

set impactpos to core:Messages:pop:content.
when not core:Messages:empty then {
  until core:Messages:empty{
    set msg to core:Messages:pop.
    set impactpos to msg:content.
  }
  log ship:altitude + "," + ship:verticalspeed + "," + ship:groundspeed + "," + impactpos:lat + "," + impactpos:lng to file.
  set vdcraft:vec to impactpos:altitudeposition(impactpos:terrainheight).
  return true.
}

set vdcraft to vecdraw(v(0,0,0),v(0,0,0),rgba(0,1,0,0),"□",2,true,0.2).

until false {
  wait 1.
}
