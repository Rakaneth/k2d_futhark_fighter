package main

import k2 "../vendor/karl2d"

FRAME_CD :: 15
PLAYER_START_SPD :: 5
BULLET_BASE_SPD :: 10

Player :: struct {
	pos:         k2.Vec2,
	dir:         k2.Vec2,
	spd:         f32,
	frame:       int,
	frame_timer: int,
	level:       int,
	bullet_pool: [4]Bullet,
}

player_init :: proc(player: ^Player) {
	player.frame = 0
	player.dir = {}
	player.spd = PLAYER_START_SPD //in tile units
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
	player.pos += player.dir * dt * GAME_UNIT * (player.spd + (0.1 * f32(player.level)))
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

player_shoot :: proc(player: ^Player) {
	for &bullet in player.bullet_pool {
		if !bullet.active {
			bullet_init(&bullet, player.pos, BULLET_BASE_SPD + (f32(player.level) * 0.5))
			bullet.active = true
			k2.play_sound(_player_shot_sound)
			break
		}
	}
}
