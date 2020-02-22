//from:@zailu12138
//着陆过程：
//加速返回发射场 - 不开减速板加速下降 - 开减速板减速下降 - 垂直减速 - 匀速下降
//代码需要至少要装 kos、trajectories两个mod
//降落不能保证每次都能准确着陆
//从 20t级火箭到 200t级火箭我都有测试，大多情况下能成功降落到楼顶，不过火箭越重偏差越大
//因为原版没有栅格舵，为了增强火箭姿态操控能力，减速板，RCS必要，动量轮，尾翼推荐

//使用FAR且加了尾翼的话，把尾翼tag设置为 tailfin
//没有用FAR且加了尾翼的话，请在着陆时手动调整尾翼偏转方向反向

clearscreen.

set ship:loaddistance:flying:pack to 1500000.
set ship:loaddistance:flying:unpack to 1450000.
set ship:loaddistance:flying:load to 1400000.
set ship:loaddistance:flying:load to 1350000.
set ship:loaddistance:suborbital:pack to 1500000.
set ship:loaddistance:suborbital:unpack to 1450000.
set ship:loaddistance:suborbital:load to 1400000.
set ship:loaddistance:suborbital:load to 1350000.
set ship:loaddistance:landed:pack to 1500000.
set ship:loaddistance:landed:unpack to 1450000.
set ship:loaddistance:landed:load to 1400000.
set ship:loaddistance:landed:load to 1350000.

ag9 off.
print "按9开始着陆程序".
wait until ag9.
print "开始".

core:Messages:clear().
processor("impact"):Connection:SendMessage("begin").
until not core:Messages:empty{
  wait 0.001.
}
set impactpos to core:Messages:pop:content.
when not core:Messages:empty then {
  until core:Messages:empty{
    set msg to core:Messages:pop.
    set impactpos to msg:content.
  }
  set vdcraft:vec to impactpos:altitudeposition(max(0,impactpos:terrainheight)).
  return true.
}

set vdcraft to vecdraw(v(0,0,0),v(0,0,0),rgba(0,1,0,0),"□",2,true,0.2).

until stage:LiquidFuel < 700 {
  print stage:LiquidFuel at (0,2).
  wait 0.001.
}

lock throttle to 0.
stage.
set ship:loaddistance:flying:pack to 1500000.
set ship:loaddistance:flying:unpack to 1450000.
set ship:loaddistance:flying:load to 1400000.
set ship:loaddistance:flying:load to 1350000.
set ship:loaddistance:suborbital:pack to 1500000.
set ship:loaddistance:suborbital:unpack to 1450000.
set ship:loaddistance:suborbital:load to 1400000.
set ship:loaddistance:suborbital:load to 1350000.
set ship:loaddistance:landed:pack to 1500000.
set ship:loaddistance:landed:unpack to 1450000.
set ship:loaddistance:landed:load to 1400000.
set ship:loaddistance:landed:load to 1350000.

wait 3.

clearscreen.
sas off.
lock steering to srfretrograde.
lock throttle to 0.
rcs on.

set vabwpos to latlng(-0.0967940250101939,-74.6200366478814).//vab西停机坪
set vabepos to latlng(-0.096772230116938,-74.6173984798422).//vab东停机坪
set lppos to latlng(-0.097206312038499,-74.5576714049082).//发射台
set ship1pos to latlng(0,-65).//船1
set ship2pos to vessel("着陆船 002"):geoposition.

set tarpos to vabwpos.//目标着陆点
// print tarpos at (0,4).

lock radaralt to ship:bounds:bottomaltradar + ship:geoposition:terrainheight - tarpos:terrainheight.//火箭底端距离着陆点高度

lock errtheta to arctan2(tarpos:lng-ship:GeoPosition:lng,tarpos:lat-ship:GeoPosition:lat).
lock fixedTarErr to 1*ship:groundspeed/(ship:body:radius*constant:pi/180).
lock fixedtarpos to latlng(tarpos:lat+fixedtarErr*cos(errtheta),tarpos:lng+fixedtarErr*sin(errtheta)).

lock errlng to fixedtarpos:lng-impactpos:lng.//预测落点与目标落点经度差
lock errlat to fixedtarpos:lat-impactpos:lat.//预测落点与目标落点纬度差

// lock errlng to tarpos:lng-impactpos:lng.//预测落点与目标落点经度差
// lock errlat to tarpos:lat-impactpos:lat.//预测落点与目标落点纬度差

brakes on.
rcs on.

lock steering to srfretrograde.

wait until (fixedtarpos:lat - ship:GeoPosition:lat)^2 + (fixedtarpos:lng - ship:GeoPosition:lng)^2 < 9.

//加速调整落点
lock corvec to heading(90-arctan2(errlat,errlng),0).//计算火箭加速朝向
if sqrt(errlat^2 + errlng^2) > 0.2{
  lock steering to corvec.
  until vang(ship:facing:Vector,corvec:Vector)<5{//等待火箭调姿
    print vang(ship:facing:Vector,corvec:Vector) at (0,2).
  }
  wait 5.

  set lastdist to sqrt(errlat^2 + errlng^2).
  until sqrt(errlat^2 + errlng^2) > lastdist and lastdist < 0.2{//这次预测落点比上次预测落点远时结束点火
    set lastdist to sqrt(errlat^2 + errlng^2).
    if lastdist > 0.01{
      set tmpvec to corvec:Vector.
    }
    lock steering to tmpvec.
    print arctan2(errlat,errlng) at (0,1).
    print vang(ship:facing:Vector,corvec:Vector) at (0,2).
    print sqrt(errlat^2 + errlng^2) at (0,4).
    lock throttle to min(1,0.5*sqrt(errlat^2 + errlng^2)).//预测落点与目标落点越近，节流阀越小
    wait 0.001.
  }
}

// lock fixedtarpos to latlng(tarpos:lat,tarpos:lng+ship:groundspeed*0.4/(ship:body:radius*constant:pi/180)).
//
// lock errlng to fixedtarpos:lng-impactpos:lng.//预测落点与目标落点经度差
// lock errlat to fixedtarpos:lat-impactpos:lat.//预测落点与目标落点纬度差

// lock errlng to tarpos:lng-impactpos:lng.//预测落点与目标落点经度差
// lock errlat to tarpos:lat-impactpos:lat.//预测落点与目标落点纬度差

//尾翼偏转反向，装了FAR且给火箭加了尾翼的需要使用此段代码，使用前需将尾翼tag设置为 tailfin
//没装FAR或者没加尾翼的可以不管下面这段代码
for tailfin in ship:partstagged("tailfin"){
  set module to tailfin:getmodule("farcontrollablesurface").
  module:setfield("标准. 控制",true).
  wait 0.001.
  module:setfield("控制偏转",-20).
  wait 0.001.
}

lock steering to srfretrograde.
lock throttle to 0.
wait 5.
rcs off.
brakes on.
clearscreen.

wait until ship:verticalspeed < 0.
rcs on.

//无减速板调整落点
//通过火箭俯仰偏航，控制减小经纬偏差，采用 pid控制
lock steering to srfretrograde.

set pitchs to pidloop(-2000,-2000,-2000,-10,10).
set pitchs:setpoint to 0.

set yaws to pidloop(-2000,-2000,-2000,-10,10).
set yaws:setpoint to 0.

wait until vang(ship:facing:Vector,srfretrograde:Vector)<10.
until sqrt(errlat^2+errlng^2) < 0.01{ //落点达到较高精度时结束，进入下一状态
  lock steering to srfretrograde + r(pitchs:update(time:seconds,errlat),yaws:update(time:seconds,errlng),0).
  print "errlat: " + errlat at (0,5).
  print "errlng: " + errlng at (0,7).
  if radaralt < 2*ship:verticalspeed^2 / (2*(ship:availablethrust/ship:mass-9.8)){  //如果高度过低时，必须结束此循环，开减速板
    break.
  }
  wait 0.001.
}

// lock steering to srfretrograde.
// wait 1.
// set lastdist to sqrt(errlat^2 + errlng^2).
// until sqrt(errlat^2 + errlng^2) > lastdist and lastdist < 0.2{
//   set lastdist to sqrt(errlat^2 + errlng^2).
//   lock steering to srfretrograde+r(-5,0,0).
//   lock throttle to min(1,0.5*sqrt(errlat^2 + errlng^2)).//预测落点与目标落点越近，节流阀越小
//   if radaralt < 2*ship:verticalspeed^2 / (2*(ship:availablethrust/ship:mass-9.8)){  //如果高度过低时，必须结束此循环，开减速板
//     break.
//   }
//   wait 0.001.
// }
// lock throttle to 0.

set pitchs to pidloop(-1000,-2000,-2000,-10,10).
set pitchs:setpoint to 0.

set yaws to pidloop(-1000,-2000,-2000,-10,10).
set yaws:setpoint to 0.
//有减速板调整落点
until false {
  lock steering to srfretrograde + r(pitchs:update(time:seconds,errlat),yaws:update(time:seconds,errlng),0).
  print "errlat: " + errlat at (0,5).
  print "errlng: " + errlng at (0,7).
  set ship:control:StarBoard to max(-1,min(1,(-errlng*cos(errtheta)+errlat*sin(errtheta))*10)).
  set ship:control:top to max(-1,min(1,(errlng*sin(errtheta)+errlat*cos(errtheta))*10)).
  if 0.5*ship:velocity:surface:sqrmagnitude/(ship:availablethrust/ship:mass-9.8) > radaralt {  //
    lock steering to up.
    break.
  }
  wait 0.001.
}
set ship:control:neutralize to true.

// lock errlng to tarpos:lng-impactpos:lng.//预测落点与目标落点经度差
// lock errlat to tarpos:lat-impactpos:lat.//预测落点与目标落点纬度差

//垂直减速兼调整落点
//调整落点采用串级控制，先根据落点经纬差调整火箭东、北方向速度的设定值，再通过火箭点火时略微的俯仰偏航改变水平速度
//如果减速过程比较缓慢，那么垂直减速段调整落点效果比较明显，
//但是现在代码基本上是让火箭以最大节流阀减速，追求减速时间短，减少dv消耗，所以这段代码调整落点的效果并不明显
set vns to pidloop(-200,-100,-100,-10,10).
set vns:setpoint to 0.
set ves to pidloop(-200,-100,-100,-10,10).
set ves:setpoint to 0.

set pitchs to pidloop(-1,-1,-1,-5,5).
set pitchs:setpoint to 0.
set yaws to pidloop(-1,-1,-1,-5,5).
set yaws:setpoint to 0.
//通过节流阀，控制火箭下降速度，采用 p控制
set thrs to pidloop(1,0,0,0,1).

when ship:velocity:surface:mag/(ship:availablethrust/ship:mass-9.8) < 3 then {
  legs on.
}

set t0 to time:seconds.
until -ship:verticalspeed < ship:availablethrust/ship:mass-9.8 or radaralt < 0 {//下降速度小于50m/s时结束循环，进入最后一阶段
  //火箭下降速度的设定值，v=sqrt(2ax)/1.8，
  //除以1.8的目的是尽可能把设定值调小，从而开到最大节流阀，尽快减速，
  //不除1.8的话因为滞后的存在可能直接坠毁，或者触地速度较大，硬靠着陆架挡住冲击
  clearscreen.
  set thrs:setpoint to min(-sqrt(2*(ship:availablethrust/ship:mass-9.8)*radaralt)/1.4,-2).
  print thrs:setpoint at (0,4).
  print "errlat: " + errlat at (0,5).
  print "errlng: " + errlng at (0,7).

  set t1 to time:seconds.

  set vn to ship:velocity:surface * north:Vector.
  set ve to ship:velocity:surface * heading(90,0):Vector.

  set t0 to t1.

  print "vn: " + vn at (0,11).
  print "ve: " + ve at (0,13).

  set ship:control:StarBoard to max(-1,min(1,(-errlng*cos(errtheta)+errlat*sin(errtheta))*5000)).
  set ship:control:top to max(-1,min(1,(errlng*sin(errtheta)+errlat*cos(errtheta))*5000)).

  set pitchs:setpoint to vns:update(time:seconds,errlat/abs(errlat)*sqrt(abs(errlat))).
  set yaws:setpoint to ves:update(time:seconds,errlng/abs(errlng)*sqrt(abs(errlng))).

  print "pitchs:setpoint: " + pitchs:setpoint at (0,15).
  print "yaws:setpoint: " + yaws:setpoint at (0,17).

  // lock steering to up + r(pitchs:update(time:seconds,vn),yaws:update(time:seconds,ve),0).
  lock steering to srfretrograde + r(pitchs:update(time:seconds,vn),yaws:update(time:seconds,ve),0).
  // lock steering to srfretrograde.
  lock throttle to thrs:update(time:seconds,ship:verticalspeed).
  wait 0.001.
}
set ship:control:neutralize to true.

set vns to pidloop(-100,0,0,-2,2).
set vns:setpoint to 0.
set ves to pidloop(-100,0,0,-2,2).
set ves:setpoint to 0.

set pitchs to pidloop(-3,0,-1,-5,5).
set pitchs:setpoint to 0.
set yaws to pidloop(-3,0,-1,-5,5).
set yaws:setpoint to 0.
//通过节流阀，控制火箭下降速度，采用 p控制
set thrs to pidloop(1,0,0,0,1).
//匀速降落兼调整落点
//和上一段代码基本一样，改动了跳出循环的条件和设定速度的参数
//有时候会因为上一段减速不够直接着陆，而不执行此段代码
//可以考虑与上一段代码合并，因为我懒所以没动这一段
clearscreen.
until ship:bounds:bottomaltradar < 0.1 or ship:verticalspeed > -0.1{ //着陆时结束程序
  set thrs:setpoint to min(-sqrt(2*(ship:availablethrust/ship:mass-9.8)*ship:bounds:bottomaltradar)/1.4,-2).
  // set thrs:setpoint to 0.
  print "errlat: " + errlat at (0,5).
  print "errlng: " + errlng at (0,7).

  set vn to ship:velocity:surface * north:Vector.
  set ve to ship:velocity:surface * heading(90,0):Vector.

  print "vn: " + vn at (0,11).
  print "ve: " + ve at (0,13).

  set ship:control:StarBoard to max(-1,min(1,(-errlng*cos(errtheta)+errlat*sin(errtheta))*5000)).
  set ship:control:top to max(-1,min(1,(errlng*sin(errtheta)+errlat*cos(errtheta))*5000)).

  set pitchs:setpoint to vns:update(time:seconds,errlat/abs(errlat)*sqrt(abs(errlat))).
  set yaws:setpoint to ves:update(time:seconds,errlng/abs(errlng)*sqrt(abs(errlng))).

  print "pitchs:setpoint: " + pitchs:setpoint at (0,15).
  print "yaws:setpoint: " + yaws:setpoint at (0,17).

  lock steering to r(up:pitch,up:yaw,ship:facing:roll) + r(pitchs:update(time:seconds,vn),yaws:update(time:seconds,ve),0).
  print "thrs:setpoint: " + thrs:setpoint at (0,0).
  lock throttle to thrs:update(time:seconds,ship:verticalspeed).
  wait 0.001.
}
set ship:control:neutralize to true.

brakes off.
unlock steering.

processor("impact"):Connection:SendMessage("end").

set ship:control:pilotmainthrottle to 0.
