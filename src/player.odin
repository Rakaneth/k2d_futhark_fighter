package main

import k2 "../vendor/karl2d"

FRAME_CD :: 2


Player :: struct {
	pos:         k2.Vec2,
	dir:         k2.Vec2,
	spd:         f32,
	frame:       int,
	frame_timer: int,
}

player_init :: proc(player: ^Player) {
	player.frame = 0
	player.dir = {}
	player.spd = 4 //in tile units
	player.frame_timer = 0
}

player_hitbox :: proc(player: Player) -> k2.Rect {
	return {player.pos.x, player.pos.y, GAME_UNIT, GAME_UNIT}
}

player_update :: proc(player: ^Player, dt: f32) {
	player.frame_timer += 1
	if player.frame_timer >= FRAME_CD {
		player.frame_timer -= FRAME_CD
		player.frame = (player.frame + 1) % 2
	}
	player.pos += player.dir * dt * GAME_UNIT * player.spd
	hb := player_hitbox(player^)


	if hb.x + hb.w >= RIGHT_EDGE {
		player.pos.x = RIGHT_EDGE - hb.w
	}

	if hb.y + hb.h >= BOT_EDGE {
		player.pos.y = BOT_EDGE - hb.h
	}

	if hb.x < LEFT_EDGE {
		player.pos.x = LEFT_EDGE
	}

	if hb.y < TOP_EDGE {
		player.pos.y = TOP_EDGE
	}
}
