package main

Timer :: struct {
	num_loops: int,
	fn:        proc(),
	elapsed:   f32,
	duration:  f32,
	infinite:  bool,
	running:   bool,
	handle:    Timer_Handle,
}

timer_start :: proc(timer: ^Timer) {
	timer.running = true
}

timer_stop :: proc(timer: ^Timer) {
	timer.running = false
}

timer_reset :: proc(timer: ^Timer) {
	timer.running = false
	timer.elapsed = 0
}

timer_update :: proc(timer: ^Timer, dt: f32) {
	if !timer.running {
		return
	}
	timer.elapsed += dt
	if timer.elapsed >= timer.duration {
		timer.fn()
		switch {
		case timer.infinite:
			timer.elapsed -= timer.duration
		case timer.num_loops > 0:
			timer.num_loops -= 1
			timer.elapsed -= timer.duration
			if timer.num_loops <= 0 {
				timer.running = false
			}
		case:
			timer.running = false
		}
	}
}
