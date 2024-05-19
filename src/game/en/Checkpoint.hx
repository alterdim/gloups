package en;

class Checkpoint extends Entity
{
    var active = false;
    var ca : dn.heaps.input.ControllerAccess<GameAction>;

    public function new(x, y)
    {
        super(x, y);
        setPosCase(x, y);
        spr.set(Assets.entities, D.entities.Flag_inactive);

    }

    override function fixedUpdate() 
        {
            super.fixedUpdate();
            if( distCase(hero)<=1 && !cd.has("pickLock"))
                {
                    onPick();
                }     
        }

        function onPick()
        {
            spr.set(Assets.entities, D.entities.Flag_active);
            hero.changeCheckpoint(this);
            
            cd.setS("pickLock", 1);
            
        }
        
        public function disable()
        {
            this.active = false;
            spr.set(Assets.entities, D.entities.Flag_inactive);
        }
}