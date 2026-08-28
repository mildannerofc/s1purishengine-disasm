#!/usr/bin/env lua

local common = require "build_tools.lua.common"

local message, abort = common.build_rom("sonic", "s1purish", "", "-p=FF", false, "https://github.com/sonicretro/s1disasm")

if message then
	exit_code = false
end

if abort then
	os.exit(exit_code, true)
end

-- Buld DEBUG ROM
message, abort = common.build_rom("sonic", "s1purish.debug", "-D __DEBUG__ -OLIST sonic.debug.lst", "-p=FF", false, "https://github.com/sonicretro/s1disasm")

if message then
	exit_code = false
end

if abort then
	os.exit(exit_code, true)
end

-- Append symbol table to the ROM.
local extra_tools = common.find_tools("debug symbol generator", "https://github.com/vladikcomper/md-modules", "https://github.com/sonicretro/s1disasm", "convsym")
if not extra_tools then
	os.exit(false)
end
os.execute(extra_tools.convsym .. " sonic.lst s1purish.bin -input as_lst -range 0 FFFFFF -exclude -filter \"z[A-Z].+\" -a")
os.execute(extra_tools.convsym .. " sonic.debug.lst s1purish.debug.bin -input as_lst -range 0 FFFFFF -exclude -filter \"z[A-Z].+\" -a")

-- Correct the ROM's header with a proper checksum and end-of-ROM value.
common.fix_header("s1purish.bin")
common.fix_header("s1purish.debug.bin")

os.exit(exit_code, false)
