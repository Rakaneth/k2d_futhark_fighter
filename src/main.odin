package main

import k2 "../vendor/karl2d"
import hm "core:container/handle_map"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "core:mem"

Timer_Handle :: hm.Handle16

SCR_W :: 800
SCR_H :: 600
WORLD_W :: 144
WORLD_H :: 108
TITLE :: "Futhark Fighter!"
NUM_FRAMES :: 18
GAME_UNIT :: 8
GAMEPAD_DEADZONE :: 0.4
ENEMY_SPAWN_BASE_CD :: 2.0
DIFF_INCREASE_BASE_CD :: 5.0

@(rodata)
LEFT_EDGE := f32(-WORLD_W / 2)

@(rodata)
RIGHT_EDGE := f32(WORLD_W / 2)

@(rodata)
TOP_EDGE := f32(-WORLD_H / 2) + 8.0

@(rodata)
BOT_EDGE := f32(WORLD_H / 2)

@(rodata)
Bonus_Rune_Frame := [Rune]int {
	.F  = 12,
	.U  = 13,
	.TH = 14,
	.A  = 15,
	.R  = 16,
	.K  = 17,
}


_cam: k2.Camera
_tex: k2.Texture
_frames: [NUM_FRAMES]k2.Rect
_explode_sound: k2.Sound
_game_over_sound: k2.Sound
_player_shot_sound: k2.Sound
_music: k2.Sound
_font: k2.Font
_player: Player
_enemies: [10]Enemy
_score := 0
_diff := 1
_bonus_runes: bit_set[Rune] = {}
_game_over: bool
_timers: hm.Dynamic_Handle_Map(Timer, Timer_Handle)
_debug_mode := false
_e_timer: Timer_Handle
_diff_timer: Timer_Handle

init :: proc() {
	k2.init(SCR_W, SCR_H, TITLE)
	_cam = {
		zoom   = f32(SCR_W) / f32(WORLD_W),
		offset = {SCR_W / 2, SCR_H / 2},
	}

	_tex = k2.load_texture_from_bytes(#load("../assets/sprites.png"))

	for &frame, i in _frames {
		x := i % 18
		y := i / 18
		frame.x = f32(x * 8)
		frame.y = f32(y * 8)
		frame.w = 8
		frame.h = 8
	}

	_explode_sound = k2.load_sound_from_bytes(#load("../assets/explode.wav"))
	_game_over_sound = k2.load_sound_from_bytes(#load("../assets/game_over.wav"))
	_player_shot_sound = k2.load_sound_from_bytes(#load("../assets/player_shot.wav"))
	_music = k2.load_sound_from_bytes(#load("../assets/music.wav"))
	_font = k2.load_font_from_bytes(#load("../assets/PressStart2P-Regular.ttf"))

	player_init(&_player)

	_e_timer = add_timer(ENEMY_SPAWN_BASE_CD, spawn_enemy, true)
	_diff_timer = add_timer(DIFF_INCREASE_BASE_CD, increase_diff, true)
	timer_start(hm.get(&_timers, _e_timer))
	timer_start(hm.get(&_timers, _diff_timer))
	spawn_enemy()

	k2.set_sound_loop(_music, true)
	k2.play_sound(_music)
}

reset_game :: proc() {
	_score = 0
	_diff = 1
	_player.level = 0

	player_init(&_player)
}

increase_diff :: proc() {
	_diff += 1
	e_timer := hm.get(&_timers, _e_timer)
	e_timer.duration = ENEMY_SPAWN_BASE_CD / (1 + f32(_diff) * 0.1)
}

input :: proc() {
	axis: k2.Vec2

	if k2.is_gamepad_active(0) {
		axis.x = k2.get_gamepad_axis(0, .Left_Stick_X)
		axis.y = k2.get_gamepad_axis(0, .Left_Stick_Y)
		if math.abs(axis.x) < GAMEPAD_DEADZONE {
			axis.x = 0
		}
		if math.abs(axis.y) < GAMEPAD_DEADZONE {
			axis.y = 0
		}
		if k2.gamepad_button_is_held(0, .Left_Face_Up) {
			axis.y += -1
		}
		if k2.gamepad_button_is_held(0, .Left_Face_Down) {
			axis.y -= -1
		}
		if k2.gamepad_button_is_held(0, .Left_Face_Left) {
			axis.x -= 1
		}
		if k2.gamepad_button_is_held(0, .Left_Face_Right) {
			axis.x += 1
		}
	} else {
		if k2.key_is_held(.A) {
			axis.x -= 1
		}

		if k2.key_is_held(.D) {
			axis.x += 1
		}

		if k2.key_is_held(.W) {
			axis.y -= 1
		}

		if k2.key_is_held(.S) {
			axis.y += 1
		}
	}

	_player.dir = linalg.normalize0(axis)

	if k2.key_went_down(.Space) || k2.gamepad_button_went_down(0, .Right_Face_Down) {
		player_shoot(&_player)
	}

	if k2.key_went_down(.Backtick) {
		_debug_mode = !_debug_mode
	}
}

add_timer :: proc(duration: f32, fn: proc(), infinite := false, num_loops := 1) -> Timer_Handle {
	t := Timer {
		duration  = duration,
		num_loops = num_loops,
		infinite  = infinite,
		fn        = fn,
	}
	ha := hm.add(&_timers, t)
	return ha
}

check_bonus_runes :: proc() {
	for rn in Rune {
		if rn not_in _bonus_runes {
			return
		}
	}
	_bonus_runes = {}
	_player.level += 1
	_score += _player.level * 1000
}

spawn_enemy :: proc() {
	for &enemy in _enemies {
		if !enemy.active {
			rn := rand.choice_enum(Rune)
			enemy_init(&enemy, rn, rand.int_max(2) == 1, _diff)
			enemy.active = true
			if enemy.horz {
				enemy.pos.y = rand.float32_range(TOP_EDGE, BOT_EDGE)
				enemy.pos.x = LEFT_EDGE
			} else {
				enemy.pos.x = rand.float32_range(LEFT_EDGE, RIGHT_EDGE)
				enemy.pos.y = TOP_EDGE
			}
			break
		}
	}
}

update :: proc() {
	dt := k2.get_frame_time()
	it := hm.iterator_make(&_timers)
	for timer, handle in hm.iterate(&it) {
		timer_update(timer, dt)
	}
	player_update(&_player, dt)
	for &enemy in _enemies {
		enemy_update(&enemy, dt)
	}
	for &bullet in _player.bullet_pool {
		bullet_update(&bullet, dt)
		if bullet.active {
			bhb := bullet_hitbox(bullet)
			for &enemy in _enemies {
				if enemy.active && k2.rect_overlapping(bhb, enemy_hitbox(enemy)) {
					enemy.active = false
					bullet.active = false
					k2.play_sound(_explode_sound)
					_score += 10 * _diff
					_bonus_runes += {enemy.e_rune}
					check_bonus_runes()
				}
			}
		}
	}
}

draw_player :: proc() {
	src := _frames[_player.frame]
	dest := player_hitbox(_player)
	k2.draw_texture_fit(_tex, src, dest)
	if _debug_mode {
		k2.draw_rect_outline(dest, 1, k2.WHITE)
	}
}

draw_enemies :: proc() {
	for enemy in _enemies {
		if !enemy.active {
			continue
		}
		src := _frames[enemy.frame]
		dest := enemy_hitbox(enemy)
		k2.draw_texture_fit(_tex, src, dest)
		if _debug_mode {
			k2.draw_rect_outline(dest, 1, k2.WHITE)
		}
	}
}

draw_bullets :: proc() {
	for bullet in _player.bullet_pool {
		if !bullet.active {
			continue
		}
		src := _frames[2]
		dest := k2.Rect{bullet.pos.x, bullet.pos.y, GAME_UNIT, GAME_UNIT}
		k2.draw_texture_fit(_tex, src, dest)
		if _debug_mode {
			hb := bullet_hitbox(bullet)
			k2.draw_rect_outline(hb, 1, k2.WHITE)
		}
	}
}

draw_game :: proc() {
	k2.set_camera(_cam)
	draw_player()
	draw_bullets()
	draw_enemies()
}

draw_hud :: proc() {
	k2.set_camera(nil)
	k2.draw_rect({0, 0, SCR_W, 32}, {192, 192, 192, 255})
	score_text := fmt.tprintf("%06d", _score)
	level_text := fmt.tprintf("LV:%02d", _player.level)
	wave_text := fmt.tprintf("D:%02d", _diff)

	k2.draw_text(score_text, {0, 0}, 32, k2.BLACK, _font)
	k2.draw_text(level_text, {7 * 32, 0}, 32, k2.BLACK, _font)
	k2.draw_text(wave_text, {13 * 32, 0}, 32, k2.BLACK, _font)

	for bonus_rune, i in Rune {
		if bonus_rune in _bonus_runes {
			src := _frames[Bonus_Rune_Frame[bonus_rune]]
			dest := k2.Rect{f32((i + 17) * 32), 0, 32, 32}
			k2.draw_texture_fit(_tex, src, dest)
		}
	}
}


draw :: proc() {
	k2.clear(k2.BLACK)
	draw_game()
	draw_hud()
	k2.present()
}

step :: proc() -> bool {
	if !k2.update() {
		return false
	}

	input()
	update()
	draw()

	free_all(context.temp_allocator)

	return true
}

shutdown :: proc() {
	hm.dynamic_destroy(&_timers)
	k2.destroy_font(_font)
	if k2.sound_is_playing(_music) {
		k2.stop_sound(_music)
	}
	k2.destroy_sound(_music)
	k2.destroy_sound(_player_shot_sound)
	k2.destroy_sound(_game_over_sound)
	k2.destroy_sound(_explode_sound)
	k2.destroy_texture(_tex)
	k2.shutdown()
}


main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		defer {
			if len(track.allocation_map) > 0 {
				for _, entry in track.allocation_map {
					fmt.eprintf("%v leaked %v bytes\n", entry.location, entry.size)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	init()
	for step() {}
	shutdown()
}
