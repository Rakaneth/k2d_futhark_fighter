package main

import k2 "../vendor/karl2d"
import "core:math"
import "core:math/linalg"

ENEMY_START_SPD :: 6

Rune :: enum {
	F,
	U,
	TH,
	A,
	R,
	K,
}

Enemy :: struct {
	pos:    k2.Vec2,
	dir:    k2.Vec2,
	spd:    f32,
	frame:  int,
	active: bool,
}

@(rodata)
Enemy_Frames := [Rune]int {
	.F  = 4,
	.U  = 5,
	.TH = 6,
	.A  = 7,
	.R  = 8,
	.K  = 9,
}

enemy_init :: proc(enemy: ^Enemy, enemy_rune: Rune) {
	enemy.frame = Enemy_Frames[enemy_rune]
	enemy.spd = ENEMY_START_SPD
}

enemy_hitbox :: proc(enemy: Enemy) -> k2.Rect {
	return {enemy.pos.x, enemy.pos.y, GAME_UNIT, GAME_UNIT}
}

enemy_update :: proc(enemy: ^Enemy, dt: f32) {
	if !enemy.active {
		return
	}

	enemy.pos.y += dt * enemy.spd * GAME_UNIT

	if enemy.pos.y >= BOT_EDGE {
		enemy.pos.y = TOP_EDGE
	}
}
