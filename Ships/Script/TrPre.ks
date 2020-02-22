function CalK{
  parameter hn.
  local K to 1.
  if hn>13000{
    set K to 1.
  }else if hn > 2500{
    set K to 1.1.
  }else{
    set K to hn*1.4e-4+0.75.
  }
  return K.
}

function CalCd{
  parameter vn.
  parameter hn.

  // local sv to 340.
  // local mach to vn/sv.
  // local Cd to 0.
  // if mach<0.5 {
  //   set Cd to 2*mach.
  // }else if mach<1 {
  //   set Cd to 18*mach-8.
  // }else if mach<1.5{
  //   set Cd to -12*mach+22.
  // }else if mach<2{
  //   set Cd to -6*mach+13.
  // }else {
  //   set Cd to -0.1*mach+1.2.
  // }
  // set K to CalK(hn).
  // set Cd to Cd/K.
  return 0.9/CalK(hn).
}

function CalDrag{
  parameter vn.
  parameter hn.

   // return 0.

  local Rc to 287.053.
  local Tc to 311.85.
  local Ec to constant:e.
  local P0 to 101.3.
  local H0 to 5600.
  local A to 7.865.

  local Cd to CalCd(vn,hn).
  local Pn to P0 * Ec^(-hn/H0).
  local f0 to 0.5 * Cd * A * Pn/(Rc*Tc) * vn^2.

//  local f1 to f0/(Cd*A) * (-0.0013*f0+5.3314).

  return f0.
}

function TrPre{
  parameter vel is ship:velocity:surface.
  parameter hgt is ship:altitude.
  parameter geop is ship:geoposition.
  parameter ms is ship:mass.

  set vel to v(vel*north:vector,vel*up:vector,vel*heading(90,0):vector).
  local Gc to constant:g.
  local dec2m to ship:body:radius*2*constant:pi/360.

  local vn to vel.
  local an to 0.
  local pn to v(0,hgt,0).
  local impactpos to latlng(geop:lat,geop:lng).
  local f0 to 0.
  local dt to 1.
  local t to 0.
  local maxT to obt:period.

  local t0 to time:seconds.

  // print vel at (0,8).
  // print hgt at (0,10).
  // print geop at (0,12).
  // print ms at (0,14).

  set tmpdrag to CalDrag(vel:mag,hgt).
  // set acc to ship:sensors:acc-ship:sensors:grav.
  // log ship:altitude + "," + vel:x + "," + vel:y + "," + vel:z + "," + tmpdrag + "," + ship:mass + "," + acc*north:vector + "," + acc*up:vector + "," + acc*heading(90,0):vector to "drag10.csv".
  print tmpdrag at (0,1).

  // print impactpos:terrainheight at (0,7).
  // print pn:y at (0,8).

  if max(0,impactpos:terrainheight) > pn:y{
    return impactpos.
  }

  local v0 to vel.
  set f0 to CalDrag(v0:mag,pn:y).
  local ra to ship:body:radius+pn:y.
  local a0 to f0/ms * (-v0:normalized) + v(0,-Gc*ship:body:mass/(ra*ra)+((v0:z+body:angularvel:mag*ra)^2+v0:x^2)/ra,0) + 0.22*min(abs(v0:z)/100,1)*vxcl(v0,v(0,1,0)):normalized.
  set dt to 0.2.

  local tv to v0 + a0*dt.
  local tp to pn + (v0+tv)/2*dt.

  set f0 to CalDrag(tv:mag,tp:y).
  set ra to ship:body:radius+tp:y.
  local a1 to f0/ms * (-tv:normalized) + v(0,-Gc*ship:body:mass/(ra*ra)+((v0:z+body:angularvel:mag*ra)^2+v0:x^2)/ra,0) + 0.22*min(abs(tv:z)/100,1)*vxcl(tv,v(0,1,0)):normalized.
  local v1 to v0 + (a0+a1)/2*dt.
  local pn to pn + (v0+v1)/2*dt.
  set t to t+dt.

//  set dec2m to (ship:body:radius+pn:y)*2*constant:pi/360.
//  set impactpos to latlng(ship:geoposition:lat+pn:x/dec2m,ship:geoposition:lng+pn:z/dec2m).
  set tmppos to impactpos.
  set impactpos to latlng(tmppos:lat + (v1:x)/(pn:y+body:radius)*dt*180/constant:pi, tmppos:lng + (v1:z)/(pn:y+body:radius)*dt*180/constant:pi).
  until max(0,impactpos:terrainheight) > pn:y{
    set a0 to a1.
    set v0 to v1.

    set dt to 10/min(50,max(1,a0:mag)).
//    set dt to 0.2.
//    log dt + "," + a0 + "," + v0 + "," + pn to test.csv.

    set tv to v0 + a0*dt.
    set tp to pn + (v0+tv)/2*dt.

    set f0 to CalDrag(tv:mag,tp:y).
    set ra to ship:body:radius+tp:y.
    set a1 to f0/ms * (-tv:normalized) + v(0,-Gc*ship:body:mass/(ra*ra)+((v0:z+body:angularvel:mag*ra)^2+v0:x^2)/ra,0) + 0.22*min(abs(tv:z)/100,1)*vxcl(tv,v(0,1,0)):normalized.

    set v1 to v0 + (a0+a1)/2*dt.
    set pn to pn + (v0+v1)/2*dt.
    set t to t+dt.

//    set dec2m to (ship:body:radius+pn:y)*2*constant:pi/360.
//    set impactpos to latlng(ship:geoposition:lat+pn:x/dec2m,ship:geoposition:lng+pn:z/dec2m).
    set tmppos to impactpos.
    set impactpos to latlng(tmppos:lat + (v1:x)/(pn:y+body:radius)*dt*180/constant:pi, tmppos:lng + (v1:z)/(pn:y+body:radius)*dt*180/constant:pi).

    if t > maxT {
      // print "here".
      break.
    }
  }
  // set ra to ship:body:radius+ship:altitude.
  // print -Gc*ship:body:mass/(ra*ra)+((vel:z+body:angularvel:mag*ra)^2+vel:x^2)/ra at(0,6).
  // print (ship:velocity:surface*heading(90,0):vector) at (0,6).

  print time:seconds - t0 at (0,4).

  print t at (0,5).
  // print impactpos:lat at (0,6).
  // print impactpos:lng at (0,7).
  return impactpos.
}
