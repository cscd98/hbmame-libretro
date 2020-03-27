-- license:BSD-3-Clause
-- copyright-holders:MAMEdev Team

---------------------------------------------------------------------------
--
--   main.lua
--
--   Rules for building main binary
--
---------------------------------------------------------------------------

function mainProject(_target, _subtarget)
if (_OPTIONS["SOURCES"] == nil) then
	if (_target == _subtarget) then
		project (_target)
	else
		if (_subtarget=="mess") then
			project (_subtarget)
		else
			project (_target .. _subtarget)
		end
	end
else
	project (_subtarget)
end
	uuid (os.uuid(_target .."_" .. _subtarget))
	kind "ConsoleApp"

	configuration { "android*" }
if _OPTIONS["osd"] == "retro" then
		linkoptions {
			"-shared",
		}
else
		targetprefix "lib"
		targetname "main"
		targetextension ".so"
		linkoptions {
			"-shared",
			"-Wl,-soname,libmain.so"
		}
end
		links {
			"EGL",
			"GLESv1_CM",
			"GLESv2",
-- RETRO HACK no sdl for libretro android
--			"SDL2",
		}
if _OPTIONS["osd"] == "retro" then

else
               links {
                        "SDL2",
                }
end
-- RETRO HACK END no sdl for libretro android
	configuration {  }

	addprojectflags()
	flags {
		"NoManifest",
		"Symbols", -- always include minimum symbols for executables
	}

	if _OPTIONS["SYMBOLS"] then
		configuration { "mingw*" }
			postbuildcommands {
				"$(SILENT) echo Dumping symbols.",
				"$(SILENT) objdump --section=.text --line-numbers --syms --demangle $(TARGET) >$(subst .exe,.sym,$(TARGET))"
			}
	end

	configuration { "x64", "Release" }
		targetsuffix ""
		if _OPTIONS["PROFILE"] then
			targetsuffix "p"
		end

	configuration { "x64", "Debug" }
		targetsuffix "d"
		if _OPTIONS["PROFILE"] then
			targetsuffix "dp"
		end

	configuration { "x32", "Release" }
		targetsuffix "32"
		if _OPTIONS["PROFILE"] then
			targetsuffix "32p"
		end

	configuration { "x32", "Debug" }
		targetsuffix "32d"
		if _OPTIONS["PROFILE"] then
			targetsuffix "32dp"
		end

	configuration { "mingw*" or "vs20*" }
		targetextension ".exe"

	configuration { "asmjs" }
		targetextension ".html"

	-- BEGIN libretro overrides to MAME's GENie build
	configuration { "libretro*" }
		kind "SharedLib"	
		targetsuffix "_libretro"
		if _OPTIONS["targetos"]=="android" then
			targetsuffix "_libretro_android"
			defines {
 				"SDLMAME_ARM=1",
			}
		elseif _OPTIONS["targetos"]=="asmjs" then
			targetsuffix "_libretro_emscripten"
			linkoptions {
				 "-s DISABLE_EXCEPTION_CATCHING=2",
				 "-s EXCEPTION_CATCHING_WHITELIST='[\"__ZN15running_machine17start_all_devicesEv\",\"__ZN12cli_frontend7executeEiPPc\"]'",			}
		elseif _OPTIONS["targetos"]=="ios-arm" or _OPTIONS["LIBRETRO_IOS"]=="1" then
			targetsuffix "_libretro_ios"
			targetextension ".dylib"
		elseif _OPTIONS["LIBRETRO_TVOS"]=="1" then
			targetsuffix "_libretro_tvos"
			targetextension ".dylib"
		elseif _OPTIONS["targetos"]=="windows" then
			targetextension ".dll"
			flags {
				"NoImportLib",
			}
		elseif _OPTIONS["targetos"]=="osx" then
			targetextension ".dylib"
		else
			targetsuffix "_libretro"
		end

		targetprefix ""

		includedirs {
			MAME_DIR .. "src/osd/libretro/libretro-internal",
		}

		files {
			MAME_DIR .. "src/osd/libretro/libretro-internal/libretro.cpp"
		}

		-- Ensure the public API is made public with GNU ld
		if _OPTIONS["targetos"]=="linux" then
			linkoptions {
				"-Wl,--version-script=" .. MAME_DIR .. "src/osd/libretro/libretro-internal/link.T",
			}
		end

	-- END libretro overrides to MAME's GENie build
	configuration { }

	if _OPTIONS["targetos"]=="android" then
-- RETRO HACK no sdl for libretro android
if _OPTIONS["osd"] == "retro" then

		if _OPTIONS["SEPARATE_BIN"]~="1" then
			targetdir(MAME_DIR)
		end
else
		includedirs {
			MAME_DIR .. "3rdparty/SDL2/include",
		}

		files {
			MAME_DIR .. "3rdparty/SDL2/src/main/android/SDL_android_main.c",
		}
		targetsuffix ""
		if _OPTIONS["SEPARATE_BIN"]~="1" then
			if _OPTIONS["PLATFORM"]=="arm" then
				targetdir(MAME_DIR .. "android-project/app/src/main/libs/armeabi-v7a")
			end
			if _OPTIONS["PLATFORM"]=="arm64" then
				targetdir(MAME_DIR .. "android-project/app/src/main/libs/arm64-v8a")
			end
			if _OPTIONS["PLATFORM"]=="x86" then
				targetdir(MAME_DIR .. "android-project/app/src/main/libs/x86")
			end
			if _OPTIONS["PLATFORM"]=="x64" then
				targetdir(MAME_DIR .. "android-project/app/src/main/libs/x86_64")
			end
		end
end
-- RETRO HACK END no sdl for libretro android
	else
		if _OPTIONS["SEPARATE_BIN"]~="1" then
			targetdir(MAME_DIR)
		end
	end

if (STANDALONE~=true) then
	findfunction("linkProjects_" .. _OPTIONS["target"] .. "_" .. _OPTIONS["subtarget"])(_OPTIONS["target"], _OPTIONS["subtarget"])
end
	links {
		"osd_" .. _OPTIONS["osd"],
	}
-- RETRO HACK no qt
if _OPTIONS["osd"]=="retro" then

else
	links {
		"qtdbg_" .. _OPTIONS["osd"],
	}
end
-- RETRO HACK END
if (STANDALONE~=true) then
	links {
		"frontend",
	}
end
	links {
		"optional",
		"emu",
	}
--if (STANDALONE~=true) then
	links {
		"formats",
	}
--end
if #disasm_files > 0 then
	links {
		"dasm",
	}
end
if (MACHINES["NETLIST"]~=null) then
	links {
		"netlist",
	}
end
	links {
		"utils",
		ext_lib("expat"),
		"softfloat",
		"softfloat3",
		"wdlfft",
		"ymfm",
		ext_lib("jpeg"),
		"7z",
	}
if not _OPTIONS["FORCE_DRC_C_BACKEND"] then
	links {
		"asmjit",
	}
end
if (STANDALONE~=true) then
	links {
		ext_lib("lua"),
		"lualibs",
		"linenoise",
	}
end
	links {
		ext_lib("zlib"),
		ext_lib("flac"),
		ext_lib("utf8proc"),
	}
if (STANDALONE~=true) then
	links {
		ext_lib("sqlite3"),
	}
end

	if _OPTIONS["NO_USE_PORTAUDIO"]~="1" then
		links {
			ext_lib("portaudio"),
		}
		if _OPTIONS["targetos"]=="windows" then
			links {
				"setupapi",
			}
		end
	end
	if _OPTIONS["NO_USE_MIDI"]~="1" then
		links {
			ext_lib("portmidi"),
		}
	end
	links {
		"bgfx",
		"bimg",
		"bx",
		"ocore_" .. _OPTIONS["osd"],
	}

	override_resources = false;

	maintargetosdoptions(_target,_subtarget)

	includedirs {
		MAME_DIR .. "src/osd",
		MAME_DIR .. "src/emu",
		MAME_DIR .. "src/devices",
		MAME_DIR .. "src/" .. _target,
		MAME_DIR .. "src/lib",
		MAME_DIR .. "src/lib/util",
		MAME_DIR .. "3rdparty",
		GEN_DIR  .. _target .. "/layout",
		GEN_DIR  .. "resource",
		ext_includedir("zlib"),
		ext_includedir("flac"),
	}

-- RETRO HACK
	if _OPTIONS["osd"]=="retro" then

       forcedincludes {
			MAME_DIR .. "src/osd/libretro/retroprefix.h"
		}

		includedirs {
			MAME_DIR .. "src/emu",
			MAME_DIR .. "src/osd",
			MAME_DIR .. "src/lib",
			MAME_DIR .. "src/lib/util",
			MAME_DIR .. "src/osd/libretro",
			MAME_DIR .. "src/osd/modules/render",
			MAME_DIR .. "3rdparty",
			MAME_DIR .. "3rdparty/bgfx/include",
			MAME_DIR .. "3rdparty/bx/include",
			MAME_DIR .. "src/osd/libretro/libretro-internal",
		}

  	if _OPTIONS["targetos"]=="windows" then
  		includedirs {
  			MAME_DIR .. "3rdparty/winpcap/Include",
		}
	end

		files {
			MAME_DIR .. "src/osd/libretro/retromain.cpp",
			MAME_DIR .. "src/osd/libretro/libretro-internal/libretro.cpp",
		}
	end
-- RETRO HACK
if (STANDALONE==true) then
	standalone();
end

if (STANDALONE~=true) then
	if _OPTIONS["targetos"]=="macosx" and (not override_resources) then
		linkoptions {
			"-sectcreate __TEXT __info_plist " .. _MAKE.esc(GEN_DIR) .. "resource/" .. _subtarget .. "-Info.plist"
		}
		custombuildtask {
			{ GEN_DIR .. "version.cpp" ,  GEN_DIR .. "resource/" .. _subtarget .. "-Info.plist",    {  MAME_DIR .. "scripts/build/verinfo.py" }, {"@echo Emitting " .. _subtarget .. "-Info.plist" .. "...",    PYTHON .. " $(1)  -p -b " .. _subtarget .. " $(<) > $(@)" }},
		}
		dependency {
			{ "$(TARGET)" ,  GEN_DIR  .. "resource/" .. _subtarget .. "-Info.plist", true  },
		}

	end
	local rctarget = _subtarget

	if _OPTIONS["targetos"]=="windows" and (not override_resources) then
		rcfile = MAME_DIR .. "scripts/resources/windows/" .. _subtarget .. "/" .. rctarget ..".rc"
		if os.isfile(rcfile) then
			files {
				rcfile,
			}
			dependency {
				{ "$(OBJDIR)/".._subtarget ..".res" ,  GEN_DIR  .. "resource/" .. rctarget .. "vers.rc", true  },
			}
		else
			rctarget = "mame"
			files {
				MAME_DIR .. "scripts/resources/windows/mame/mame.rc",
			}
			dependency {
				{ "$(OBJDIR)/mame.res" ,  GEN_DIR  .. "resource/" .. rctarget .. "vers.rc", true  },
			}
		end
	end

	local mainfile = MAME_DIR .. "src/".._target .."/" .. _subtarget ..".cpp"
	if not os.isfile(mainfile) then
		mainfile = MAME_DIR .. "src/".._target .."/" .. _target ..".cpp"
	end
	files {
		mainfile,
--		MAME_DIR .. "src/version.cpp",
		GEN_DIR .. "version.cpp",
		GEN_DIR  .. _target .. "/" .. _subtarget .."/drivlist.cpp",
	}

	if (_OPTIONS["SOURCES"] == nil) then

		if os.isfile(MAME_DIR .. "src/".._target .."/" .. _subtarget ..".flt") then
			dependency {
			{
				GEN_DIR  .. _target .. "/" .. _subtarget .."/drivlist.cpp",  MAME_DIR .. "src/".._target .."/" .. _target ..".lst", true },
			}
			custombuildtask {
				{ MAME_DIR .. "src/".._target .."/" .. _subtarget ..".flt" ,  GEN_DIR  .. _target .. "/" .. _subtarget .."/drivlist.cpp",    {  MAME_DIR .. "scripts/build/makedep.py", MAME_DIR .. "src/".._target .."/" .. _target ..".lst"  }, {"@echo Building driver list...",    PYTHON .. " $(1) driverlist $(2) -f $(<) > $(@)" }},
			}
		else
			if os.isfile(MAME_DIR .. "src/".._target .."/" .. _subtarget ..".lst") then
				custombuildtask {
					{ MAME_DIR .. "src/".._target .."/" .. _subtarget ..".lst" ,  GEN_DIR  .. _target .. "/" .. _subtarget .."/drivlist.cpp",    {  MAME_DIR .. "scripts/build/makedep.py" }, {"@echo Building driver list...",    PYTHON .. " $(1) driverlist $(<) > $(@)" }},
				}
			else
				dependency {
				{
					GEN_DIR  .. _target .. "/" .. _target .."/drivlist.cpp",  MAME_DIR .. "src/".._target .."/" .. _target ..".lst", true },
				}
				custombuildtask {
					{ MAME_DIR .. "src/".._target .."/" .. _target ..".lst" ,  GEN_DIR  .. _target .. "/" .. _target .."/drivlist.cpp",    {  MAME_DIR .. "scripts/build/makedep.py" }, {"@echo Building driver list...",    PYTHON .. " $(1) driverlist $(<) > $(@)" }},
				}
			end
		end
	end

	if (_OPTIONS["SOURCES"] ~= nil) then
			dependency {
			{
				GEN_DIR  .. _target .. "/" .. _subtarget .."/drivlist.cpp",  MAME_DIR .. "src/".._target .."/" .. _target ..".lst", true },
			}
			custombuildtask {
				{ GEN_DIR .. _target .."/" .. _subtarget ..".flt" ,  GEN_DIR  .. _target .. "/" .. _subtarget .."/drivlist.cpp",    {  MAME_DIR .. "scripts/build/makedep.py", MAME_DIR .. "src/".._target .."/" .. _target ..".lst"  }, {"@echo Building driver list...",    PYTHON .. " $(1) driverlist $(2) -f $(<) > $(@)" }},
			}
	end

	configuration { "mingw*" }
		custombuildtask {
			{ GEN_DIR .. "version.cpp" ,  GEN_DIR  .. "resource/" .. rctarget .. "vers.rc",    {  MAME_DIR .. "scripts/build/verinfo.py" }, {"@echo Emitting " .. rctarget .. "vers.rc" .. "...",    PYTHON .. " $(1)  -r -b " .. rctarget .. " $(<) > $(@)" }},
--			{ MAME_DIR .. "src/version.cpp" ,  GEN_DIR  .. "resource/" .. rctarget .. "vers.rc",    {  MAME_DIR .. "scripts/build/verinfo.py" }, {"@echo Emitting " .. rctarget .. "vers.rc" .. "...",    PYTHON .. " $(1)  -r -b " .. rctarget .. " $(<) > $(@)" }},
		}

	configuration { "vs20*" }
		prebuildcommands {
			"mkdir \"" .. path.translate(GEN_DIR  .. "resource/","\\") .. "\" 2>NUL",
			"@echo Emitting ".. rctarget .. "vers.rc...",
			PYTHON .. " \"" .. path.translate(MAME_DIR .. "scripts/build/verinfo.py","\\") .. "\" -r -b " .. rctarget .. " \"" .. path.translate(GEN_DIR .. "version.cpp","\\") .. "\" > \"" .. path.translate(GEN_DIR  .. "resource/" .. rctarget .. "vers.rc", "\\") .. "\"" ,
		}
end

	configuration { }

	if _OPTIONS["DEBUG_DIR"]~=nil then
		debugdir(_OPTIONS["DEBUG_DIR"])
	else
		debugdir (MAME_DIR)
	end
	if _OPTIONS["DEBUG_ARGS"]~=nil then
		debugargs (_OPTIONS["DEBUG_ARGS"])
	else
		debugargs ("-window")
	end

end
