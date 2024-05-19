package en;

import dn.heaps.assets.SfxDirectory;
import dn.heaps.input.Controller.PadButton;
import dn.Log;

class Hero extends Entity
{
    var ca : dn.heaps.input.ControllerAccess<GameAction>;
    var ctrlQueue : ControllerQueue<GameAction>;
    var walkSpeed = 0.;
	var jumpForce = 0.;
	var canDash = true;
	var canDoubleJump = true;
	var music : hxd.snd.Channel;

	var lastCheckPoint : Checkpoint;

	// This is TRUE if the player is not falling
	var onGround(get,never) : Bool;
        inline function get_onGround() return !destroyed && yr==1 && vBase.dy==0 && level.hasCollision(cx,cy+1);
	var onLeftWall(get, never) : Bool;
		inline function get_onLeftWall() return !destroyed && xr <= 0.2 && level.hasCollision(cx-1, cy);
	var onRightWall(get, never) : Bool;
		inline function get_onRightWall() return !destroyed && xr >= 0.8 && level.hasCollision(cx+1, cy);
    
    public function new(x, y)
        {
            super(x, y);
			
            hei = 8;
			startState(HERO_IDLE);

            var c = new Col(0x1e65e9);

            ca = App.ME.controller.createAccess();
		    ca.lockCondition = ()->App.ME.anyInputHasFocus() || Window.hasAnyModal();
		    ctrlQueue = new ControllerQueue(ca);

            spr.set(Assets.player);
			spr.anim.registerStateAnim(D.player.Idle, 5, () -> state == HERO_IDLE);
			spr.anim.registerStateAnim(D.player.Jumping, 5, () -> state == HERO_JUMPING);
			spr.anim.registerStateAnim(D.player.Squish, 5, () -> state == HERO_SQUISH);
			spr.anim.registerStateAnim(D.player.Walk, 5, () -> state == HERO_DASHING);
            spr.setCenterRatio();

            // Start point using level entity "PlayerStart"
		    var start = level.data.l_Entities.all_PlayerStart[0];
		    if( start!=null )
			    setPosCase(start.cx, start.cy);
			lastCheckPoint = new Checkpoint(start.cx, start.cy);

		    // Misc inits
		    vBase.setFricts(0.75, 0.94);

		    // Camera tracks this
		    camera.trackEntity(this, true);
		    camera.clampToLevelBounds = true;

		    // Init controller
		    ca = App.ME.controller.createAccess();
		    ca.lockCondition = Game.isGameControllerLocked;

			//music = hxd.Res.sfx.beg.play(true);
			
        }

        /** X collisions **/
	    override function onPreStepX() 
        {
		    super.onPreStepX();

		    // Right collision
		    if (xr>0.8 && level.hasCollision(cx+1,cy))
			{
				xr = 0.8;
				vBase.dx = 0;
			}

		    // Left collision
		    if (xr<0.2 && level.hasCollision(cx-1,cy))
			{
				xr = 0.2;
				vBase.dx = 0;
			}
			    
	    }

        /** Y collisions **/
	    override function onPreStepY() 
        {
		    super.onPreStepY();

		    // Land on ground
		    if( yr>1 && level.hasCollision(cx,cy+1) ) 
            {
			    setSquashY(0.5);
			    vBase.dy = 0;
			    vBump.dy = 0;
			    yr = 1;
			    ca.rumble(0.2, 0.06);
			    onPosManuallyChangedY();
		    }

		    // Ceiling collision
		    if( yr<0.2 && level.hasCollision(cx,cy-1) )
			    yr = 0.2;
	    }

        /**
		Control inputs are checked at the beginning of the frame.
		VERY IMPORTANT NOTE: because game physics only occur during the `fixedUpdate` (at a constant 30 FPS), 
		no physics increment should ever happen here! What this means is that you can SET a physics value (eg. see the Jump below), 
		but not make any calculation that happens over multiple frames (eg. increment X speed when walking).
	**/
	    override function preUpdate() {
		    super.preUpdate();

		    walkSpeed = 0;
		    if (onGround)
			{
				cd.setS("recentlyOnGround", 0.1); // allows "just-in-time" jumps
				canDash = true;
				canDoubleJump = true;
				startState(HERO_IDLE);
			}

		    // Jump
		    if(!(state == HERO_SQUISH) && (cd.has("recentlyOnGround") || canDoubleJump) && ca.isPressed(Jump) ) {
				
				if (!onGround && canDoubleJump)
					{
						canDoubleJump = false;
						startState(HERO_JUMPING);
						vBase.dy = -0.55;
					}
				else
				{
					vBase.dy = -0.55;
				}
			    
			    setSquashX(1.5);
			    cd.unset("recentlyOnGround");
			    fx.dotsExplosionExample(centerX, centerY, 0xffcc00);
			    ca.rumble(0.05, 0.06);
				hxd.Res.sfx.jump.play();
		    }
			// Wall Jump
			else if (state == HERO_SQUISH && ca.isPressed(Jump))
				{

					if (onRightWall && !onGround)
					{
						vBase.dx = -0.8;
						vBase.dy = -0.5;
						startState(HERO_DASHING);
					}
					else if (onLeftWall && !onGround)
					{
						vBase.dx = 0.8;
						vBase.dy = -0.5;
						startState(HERO_DASHING);
					}
					
				}

			// Slam
			if (!onGround && ca.isPressed(Slam))
				{
					vBase.dy = 1.3;
					vBase.dx = 0;
					setSquashY(2);
					fx.dotsExplosionExample(centerX, centerY, 0x00ffff);
				}

			// Walk
		    if( !isChargingAction() && ca.getAnalogDist2(MoveLeft,MoveRight)>0 && !(state == HERO_SQUISH) ) {
			    // As mentioned above, we don't touch physics values (eg. `dx`) here. We just store some "requested walk speed", which will be applied to actual physics in fixedUpdate.
			    walkSpeed = ca.getAnalogValue2(MoveLeft,MoveRight); // -1 to 1
			}
			// Dash
			if (canDash && ca.isPressed(Dash))
			{
				canDash = false;
				vBase.dy = 0;
				vBase.dx = ca.getAnalogValue2(MoveLeft, MoveRight) * 1.3;
				setSquashX(2);
				fx.dotsExplosionExample(centerX, centerY, 0x00ff11);
				ca.rumble(0.05, 0.06);
				startState(HERO_DASHING);
			}
			
			if (state == HERO_DASHING && ((onRightWall && vBase.dx > 0) || onLeftWall && vBase.dx < 0))
			{
				cd.setS("dash_time", 0);
				startState(HERO_SQUISH);
				 dir = onRightWall ? -1 : 1;
			}
	

	}


	override function fixedUpdate() 
        {
		super.fixedUpdate();

		// Gravity
		if( !onGround && !(state == HERO_SQUISH))
		{
			vBase.dy += 0.05;
		}

		// Apply requested walk movement
		if( walkSpeed !=0)
		{
			vBase.dx += walkSpeed * 0.075; // some arbitrary speed
		}

		


	}

	override function canChangeStateTo(from:State, to:State) {
		if (from == State.HERO_IDLE && to == State.HERO_SQUISH)
			{
				return false;
			}
		return true;
	}

	public function restoreJumps()
		{
			canDoubleJump = true;
			canDash = true;
		}
	
	public function return_to_checkpoint()
		{
			setPosCase(lastCheckPoint.cx, lastCheckPoint.cy);
		}

	override function onStateChange(old:State, newState:State)
		{
			switch (newState)
			{
				case HERO_IDLE: {
					spr.set(Assets.player, D.player.Idle);
					// trace("idle");  
				}
				case HERO_SQUISH: {
					//spr.set(Assets.player, D.player.Squish);
					vBase.dy = 0;
					hxd.Res.sfx.ploush.play();
					//trace("squish");
				}
				case HERO_DASHING: {
				//	spr.set(Assets.player, D.player.Walk);
					//trace("dash");
					cd.setS("dash_time", 1);
					hxd.Res.sfx.ok2.play();
					cd.onComplete("dash_time", () -> {
						startState(HERO_IDLE);
					});
				};
				case HERO_JUMPING: {
					//trace("jumping");
				//	spr.set(Assets.player, D.player.Jumping);
				}
				default : spr.set(Assets.player, D.player.Idle);
			}
		}
	
		public function changeCheckpoint(newCheck : Checkpoint)
		{
			if (newCheck != lastCheckPoint)
			{
				lastCheckPoint.disable();
				lastCheckPoint = newCheck;
			}
			
		}

}