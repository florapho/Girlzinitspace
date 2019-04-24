--girls in space
--shooter game by f2it

function _init()
 t=0
 ctime = {m=0,s=0,ms=0}
 music(11)
 
--make ship 
 ship = {
  sp=13,
  x=60,
  y=100,
  h=4,
  p=0,
  t=0,
  imm=false,
  box = {x1=0,y1=0,x2=7,y2=7}}
 bullets = {}
 explosions = {}
 stars = {}
--make mob monster boss boss2
 enemies = {}
 monster = {
 	s=17,
 	x=50,
 	y=50,
 	r=80,
 	box = {x1=0,y1=0,x2=17,y2=17}}
 	boss = {
 	s=128,
 	x=30,
 	y=50,
 	r=80,
 	box = {x1=0,y1=0,x2=7,y2=7}}
 boss2 = {
 	s=128,
 	x=60,
 	y=200,
 	r=80,
 	box = {x1=0,y1=0,x2=7,y2=7}}
-- make stars
 for i=1,128 do
  add(stars,{
   x=rnd(128),
   y=rnd(128),
   s=rnd(2)+1
  })
 end 

--init screen shake
	scr = {
	x = 0,
	y = 0,
	shake = 0,
	intensity = 1
	}
	
	start()
end

function start()
 _update = update_menu
 _draw = draw_menu
end

function time_manager()
	ctime.ms += 1/30
	if (ctime.ms >= 1) then
		ctime.ms = 0
		ctime.s += 1
		if (ctime.s >= 60) then
			ctime.s = 0
			ctime.m += 1
		end
	end
end


function update_menu()
	cls()
	if (btn(4) and btn(5)) then
	_update = update_game
	_draw = draw_game
	end
end

function draw_menu()
	cls()
	map(18,0, 0,0, 18,18)
	print("  vaisseau alpha! vous devez \nretablir la memoire collective!",1,90)
	print("press x+c to begin",30,110,7)
 end

function respawn()
 local n = flr(rnd(9))+2
 for i=1,n do
  local d = -1
  if rnd(1)<0.5 then d=1 end
 add(enemies, {
  sp=19,
  m_x=i*16,
  m_y=-20-i*8,
  d=d,
  x=-32,
  y=-32,
  r=12,
  box = {x1=0,y1=0,x2=8,y2=5}
 })
 end
end


function screenshake(nb)
	scr.shake = nb
end


function game_over()
 _update = update_over
 _draw = draw_over
end

function update_over()
--to do
end

function draw_over()
 cls()
 print("game over",50,50,4)
 print("level score:"..ship.p,50,60,10)
end

--box collision
function abs_box(s)
 local box = {}
 box.x1 = s.box.x1 + s.x
 box.y1 = s.box.y1 + s.y
 box.x2 = s.box.x2 + s.x
 box.y2 = s.box.y2 + s.y
 return box
end

function coll(a,b)
 -- todo
 local box_a = abs_box(a)
 local box_b = abs_box(b)
 
 if box_a.x1 > box_b.x2 or
    box_a.y1 > box_b.y2 or
    box_b.x1 > box_a.x2 or
    box_b.y1 > box_a.y2 then
    return false
 end

 return true  
end

function explode(x,y)
 add(explosions,{x=x,y=y,t=0})
 sfx(2)
end

function fire()
 local b = {
  sp=35,
  x=ship.x,
  y=ship.y,
  dx=0,
  dy=-3,
  box = {x1=2,y1=0,x2=5,y2=4}
 }
 add(bullets,b)
end


function update_game()
 t=t+1
 time_manager()
 
	--level 1 
	monster.x = monster.r*sin(t/150)
 monster.y = monster.r*cos(t/150)

	--coll monster vs ship
  for mo in all(monster) do
  	print("hello coll monster",50,50)
   if coll(ship,mo) and not ship.imm then
     ship.imm = true
     ship.h -= 1
     sfx(1)
     if ship.h <= 0 then
      game_over()
     end  
   end  
   if mo.x < 0 then
    del(monster,mo)
   end 
  end
  --

 --level 2 
 if ship.imm then
  ship.t += 1
  if ship.t >30 then
   ship.imm = false
   ship.t = 0
  end
 end
 
 for st in all(stars) do
  st.y += st.s
  if st.y >= 128 then
   st.y = 0
   st.x=rnd(128)
  end
 end
 
 for ex in all(explosions) do
  ex.t+=1
  if ex.t == 13 then
   del(explosions, ex)
  end
 end
 
 if #enemies <= 0 then
  respawn()
 end
 
 --coll mob vs ship
 for e in all(enemies) do
  e.m_y += 1.3
  e.x = e.r*sin(e.d*t/50) + e.m_x
  e.y = e.r*cos(t/50) + e.m_y
  if coll(ship,e) and not ship.imm then
    ship.imm = true
    ship.h -= 1
    sfx(1)
    if ship.h <= 0 then
     game_over()
    end
  
  end 
  if e.y > 150 then
   del(enemies,e)
  end
 end
  
 for b in all(bullets) do
  b.x+=b.dx
  b.y+=b.dy
  if b.x < 0 or b.x > 128 or
   b.y < 0 or b.y > 128 then
   del(bullets,b)
  end
  
  for e in all(enemies) do
   if coll(b,e) then
    del(enemies,e)
    ship.p += 1
    explode(e.x,e.y)
   end
  end
 end
 if(t%6<3) then
  ship.sp=13
 else
  ship.sp=14
 end
 
 if btn(0) then ship.x-=1 end
 if btn(1) then ship.x+=1 end
 if btn(2) then ship.y-=1 end
 if btn(3) then ship.y+=1 end
 if btnp(4) then fire() end
 
 if ship.x < 1 then ship.x = 1 end
 if ship.x > 120 then ship.x = 120 end
 if ship.y < 1 then ship.y = 1 end
 if ship.y > 120 then ship.y = 120 end
  	
end

function boss()
 	local bo = {
 	sp=17,
		x=60,
		y=30,
		dy=rnd(1),
		box={x1=0,y1=0,x2=7,y2=7}
 	}
 	add(boss,bo)
 	return bo
end

function draw_boss()
	if boss.y > 0 then boss.y +=1 end
	if boss.y > 120 then boss.y = 1 end
	spr(boss.s,boss.x,boss.y,2,2)
end

function draw_boss2()
	if boss2.y > 0 then boss2.y +=1 end
	if boss2.y > 120 then boss2.y = 1 end
	spr(boss2.s,boss2.x,boss2.y,2,2)
end

function camera_pos()
	if (scr.shake > 0) then
		scr.x = (rnd(2)-1)*scr.intensity
		scr.y = (rnd(2)-1)*scr.intensity
		scr.shake -=1
	else
		scr.x = 0
		scr.y = 0
	end
	camera(scr.x,scr.y)
end


function draw_game()
 cls()
 camera_pos()
 	
 --acess boss level1
 if ship.p > 1 and ship.p < 20 then 
 	for e in all(bullets) do
 		if coll(e,monster) then
 			print("yeah",50,50)
 			screenshake(20)
 			explode(monster.x,monster.y)
  			for n=1,10 do
    	circfill(rnd(128), rnd(128), 6)
  			end
  			ship.p += 1
 		end
 		print("attention vaisseau alpha\n sentinelles en orbite",10,110)
 	end
  spr(monster.s,monster.x,monster.y,2,2)
 	--coll monster vs ship
  for mo in all(monster) do
   if coll(ship,mo) and not ship.imm then
     ship.imm = true
     ship.h -= 1
     sfx(1)
     if ship.h <= 0 then
      game_over()
     end  
   end  
   if mo.x < 0 then
    del(monster,mo)
   end 
  end
  --
 end

 --acess boss level2
 if ship.p > 20 and ship.p < 30 then
 print("          bravo !\n tu as libere ada lovelace\n a l'origine des machines\n      informatiques :)",10,100)
 for st in all(stars) do	
 		st.s=rnd(4)+1
 	end
 end
 
 if ship.p > 30 and ship.p < 40 then	
 print("attention vaisseau alpha\n  voila les gardiens\n du !! patriarcats !!",18,110)
 end
 
 if ship.p > 40 and ship.p < 60 then	
 print("           bravo !\n  tu as libere grace hopper\n  creatrice du cobol et de\n         l'univac i :)",10,100)
 end
 	
 if ship.p > 30 then 
 	for st in all(stars) do	
 		st.s=rnd(8)+1
 	end
 	for e in all(bullets) do
 		if coll(e,boss) then
 			print("yeah continue",50,50)
 			screenshake(20)
 			explode(boss.x,boss.y)
  			for n=1,10 do
    	circfill(rnd(128), rnd(128), 6)
  			end
  			ship.p += 1
 		end
 	end
 	for e in all(bullets) do
 		if coll(e,boss2) then
 			print("yeah continue",50,50)
 			screenshake(20)
 			explode(boss2.x,boss2.y)
  			for n=1,10 do
    	circfill(rnd(128), rnd(128), 6)
  			end
  			ship.p += 1
 		end
 	end
  draw_boss()
  draw_boss2()
  --coll monster vs ship
  for bo in all(boss) do
   if coll(bo,ship) and not ship.imm then
     ship.imm = true
     ship.h -= 1
     sfx(1)
     if ship.h <= 0 then
      game_over()
     end  
   end  
   if bo.x < 0 then
    del(boss,bo)
   end 
  end
  --
 end
 ----------
 
 for st in all(stars) do
  pset(st.x,st.y,6)
 end
 
 print(ctime.m .. ":" ..ctime.s,0,10,11)
 print("score:"..ship.p,0,3,11)
 if not ship.imm or t%8 < 4 then
  spr(ship.sp,ship.x,ship.y)
 end
 
 for ex in all(explosions) do
  circ(ex.x,ex.y,ex.t/2,8+ex.t%3)
 end
  
 for b in all(bullets) do 
  spr(b.sp,b.x,b.y)
 end
 
 for e in all(enemies) do
  spr(e.sp,e.x,e.y)
 end

--ship hearts 
 for i=1,4 do
  if i<=ship.h then 
  spr(36,80+8*i,0)
  else
  spr(37,80+8*i,0)
  end
 end
 
end