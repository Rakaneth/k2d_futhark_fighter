package main

import k2 "../vendor/karl2d"

Bullet :: struct {
	pos:    k2.Vec2,
	active: bool,
	spd:    f32,
}

bullet_init :: proc(bullet: ^Bullet, pos: k2.Vec2, spd: f32) {
	bullet.pos = pos
	bullet.spd = spd
}

bullet_hitbox :: proc(bullet: Bullet) -> k2.Rect {
	return {bullet.pos.x + 2, bullet.pos.y, 4, GAME_UNIT}
}

bullet_update :: proc(bullet: ^Bullet, dt: f32) {
	if !bullet.active {
		return
	}
	bullet.pos.y -= dt * bullet.spd * GAME_UNIT
	if bullet.pos.y + 8 <= TOP_EDGE {
		bullet.active = false
	}
}
