package en;

class Spikes extends Entity
{
    public function new(x, y)
        {
            super(x, y);
            hei = 16;
            setPosCase(x, y);
            spr.set(Assets.entities, D.entities.Spikes);
            spr.setCenterRatio(0.5, 1);
        }

        override function fixedUpdate() 
            {
                super.fixedUpdate();
                if( distCase(hero)<=1 && !cd.has("pickLock") )
                    {
                        hero.return_to_checkpoint();
                    }     
            }
}