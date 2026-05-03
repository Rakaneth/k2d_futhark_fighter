package main

import k2 "../vendor/karl2d"
import "core:math"
import "core:math/linalg"

ENEMY_START_SPD :: 5

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
	t:      f32,
	horz:   bool,
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


enemy_init :: proc(enemy: ^Enemy, enemy_rune: Rune, horz: bool) {
	enemy.frame = Enemy_Frames[enemy_rune]
	enemy.spd = ENEMY_START_SPD
	enemy.dir = {0, 1}
	enemy.horz = horz
}

enemy_hitbox :: proc(enemy: Enemy) -> k2.Rect {
	return {enemy.pos.x, enemy.pos.y, GAME_UNIT, GAME_UNIT}
}

enemy_update :: proc(enemy: ^Enemy, dt: f32) {
	if !enemy.active {
		return
	}

	enemy.t += dt / 3
	if enemy.t >= 1 {
		enemy.t -= 1
	}

	if enemy.horz {
		enemy.pos.x += enemy.spd * GAME_UNIT * dt
		enemy.pos.y = math.sin(enemy.t * math.TAU) * enemy.spd * GAME_UNIT
	} else {
		enemy.pos.x = math.sin(enemy.t * math.TAU) * enemy.spd * GAME_UNIT
		enemy.pos.y += enemy.spd * GAME_UNIT * dt
	}

	if enemy.pos.y >= BOT_EDGE {
		enemy.pos.y = TOP_EDGE
	}

	if enemy.pos.y < TOP_EDGE {
		enemy.pos.y = BOT_EDGE
	}

	if enemy.pos.x >= RIGHT_EDGE {
		enemy.pos.x = LEFT_EDGE
	}

	if enemy.pos.x < LEFT_EDGE {
		enemy.pos.x = RIGHT_EDGE
	}
}
