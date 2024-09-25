module main

import os

const global_size = 4
const local_size  = 4

fn inc(n &u8) {
    unsafe {
        if *n == local_size - 1 {*n = 0}
        else {(*n)++}
    }
}

fn dec(n &u8) {
    unsafe {
        if *n == 0 {*n = local_size - 1}
        else {(*n)--}
    }
}

fn ginc(n &u8) {
    unsafe {
        if *n == global_size - 1 {*n = 0}
        else {(*n)++}
    }
}

fn gdec(n &u8) {
    unsafe {
        if *n == 0 {*n = global_size - 1}
        else {(*n)--}
    }
}

fn print_mem(mem [][]u8) {
    for i in 0 .. global_size {
        for j in 0 .. local_size {
            print('${mem[i][j]} ')
        }
        println('')
    }
    println('=====')
}

fn process_code(code string) {
    mut mem := [][]u8{len: global_size, init: []u8{len: local_size}}
    mut gptr := u8(0)
    mut lptr := u8(0)
    mut local := false
    mut loop_stack := []u32{}
	mut i := u32(0)

    for ; i < code.len; i++ {
        c := code[i]
        if c.is_digit() {
			if i == 0 {
				println('Error: Numbers can only be used with >, <, +, or -')
				return	
			}
            mut count := 0
            for i < code.len && code[i].is_digit() {
                count = count * 10 + int(code[i] - `0`)
                i++
			} i-- 
			if count == 0 {mem[gptr][lptr] = 0}
			else {
            	prev_char := code[i - "${count}".len]
				match prev_char {
					`>` { 
						for _ in 1 .. count {if local{inc(&lptr)}else{ginc(&gptr)}}
					}
					`<` { 
						for _ in 1 .. count {if local{dec(&lptr)}else{gdec(&gptr)}}
					}
					`+` { 
						for _ in 1 .. count { mem[gptr][lptr]++ }
					}
					`-` { 
						for _ in 1 .. count { mem[gptr][lptr]-- }
					}
                    `)` {
                        if local {
                            mem[gptr][(lptr+count)%local_size] += mem[gptr][lptr]
                        } else {
                            mem[(gptr+count)%global_size][lptr] += mem[gptr][lptr]
                        }
                    }
                    `(` {
                        if local {
                            mem[gptr][(lptr-count)%local_size] += mem[gptr][lptr]
                        } else {
                            mem[(gptr-count)%global_size][lptr] += mem[gptr][lptr]
                        }
                    }
					else {
						println('Error: Numbers can only be used with >, <, +, or -')
						return
					}
				}
			}
            continue
        }

        match c {
            `>` {
                if local { inc(&lptr) } 
                else { ginc(&gptr) }
            }
            `<` {
                if local { dec(&lptr) } 
                else { gdec(&gptr) }
            }
            `+` { mem[gptr][lptr]++ }
            `-` { mem[gptr][lptr]-- }
            `.` { print(mem[gptr][lptr].ascii_str()) }
            `,` { print_mem(mem) } //TODO: now it is being used for debug. Rewrite
            `@` { 
                local = !local
                lptr = 0 
            }
            `[` {
                if mem[gptr][lptr] == 0 {
                    mut open_brackets := 1
                    for open_brackets > 0 && i < code.len - 1 {
                        i++
                        if code[i] == `[` {
                            open_brackets++
                        } else if code[i] == `]` {
                            open_brackets--
                        }
                    }
                } else {
                    loop_stack << i
                }
            }
            `]` {
                if mem[gptr][lptr] != 0 {
                    i = loop_stack.last() 
				} else {
                    loop_stack.delete_last()
				}
            }
            `!` {
                for idx in 1 .. local_size {mem[gptr][idx]=0}
            } 
            else {}
        }
    }
}

fn main() {
    args := os.args
    if args.len < 2 {
        println("No input given. Exiting...")
        return
    }
    if !os.exists(args[1]) {
        println("File " + args[1] + " doesn't exist!")
        return
    }
    if !args[1].ends_with(".mtf") {
        println(args[1] + " is not an Optifuck file!")
        return
    }

    code := fn (path string) string {
        input := os.read_file(path) or {
            panic("Failed to read file: ${err}")
        }
        allowed := ['>', '<', '+', '-', '[', ']', ',', '.', '@', '!', ')', '(']
        mut code_ := ""
        for c in input {
            if allowed.contains(c.ascii_str()) || c.is_digit() { 
                code_ += c.ascii_str() 
            }
        }
        return code_
    }(args[1])
    
    println(code)
    process_code(code)
}
