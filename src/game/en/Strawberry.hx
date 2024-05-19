package en;

import hxd.Res;

class Strawberry extends Entity
{
    var active = true;
    public function new(x, y)
        {
            super(x, y);
            hei = 8;
            setPosCase(x, y);
            spr.set(Assets.entities, D.entities.Strawberry);
            spr.setCenterRatio();
            cd.setS("pickupcd", 0);
            
        }

        override function fixedUpdate() 
        {
            super.fixedUpdate();
            if( distCase(hero)<=1 && !cd.has("pickLock") )
                {
                    onPick();
                }     
        }

        function onPick()
        {
            if (active == true)
                {
                    fx.dotsExplosionExample(centerX, centerY, 0xff0000);
                    Res.sfx.pickup.play();
                    hero.restoreJumps();
                    spr.alpha = 0.3;
                    cd.setS("pickupcd", 3);
                    cd.onComplete("pickupcd", () -> {
                        active = true;
                        spr.alpha =  1;
                    });
                    active = false;
                }
            
        }
}