#!/usr/bin/env python3
"""Build or SWD-flash the current CMake project. Python 3.8+, standard library only."""

import argparse
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys

# Project choices from CMakeLists.txt and the previously working SWD task.
BOARD = "pico_w"
TARGET = "blink"
CHIP = "rp2040"
SDK_VERSION = "2.3.1"
TOOLCHAIN_VERSION = "15_2_Rel1"
CMAKE_VERSION = "v4.3.4"
NINJA_VERSION = "v1.13.2"
OPENOCD_VERSION = "0.12.0+dev"

WINDOWS = os.name == "nt"
EXE = ".exe" if WINDOWS else ""
TOOLS = Path(os.environ.get("PICO_TOOLS_HOME", str(Path.home() / ".pico-sdk"))).expanduser()


def find_project(start):
    """Find the nearest CMakeLists.txt, starting at a folder (or source file)."""
    directory = Path(start).expanduser().resolve()
    if directory.is_file():
        directory = directory.parent
    for candidate in (directory,) + tuple(directory.parents):
        if (candidate / "CMakeLists.txt").is_file():
            return candidate
    raise RuntimeError("No CMakeLists.txt found at or above {}. Open the project folder first.".format(directory))


def find_tool(variable, name, packaged_paths):
    """Explicit override, then the existing tool bundle, then normal PATH."""
    override = os.environ.get(variable)
    if override:
        path = Path(override).expanduser()
        if path.is_file():
            return str(path.resolve())
        found = shutil.which(override)
        if found:
            return found
        raise RuntimeError("{} does not name an installed executable: {}".format(variable, override))
    for relative in packaged_paths:
        path = TOOLS / relative
        if path.is_file() and os.access(str(path), os.X_OK):
            return str(path.resolve())
    found = shutil.which(name)
    if not found:
        raise RuntimeError("Missing {}. Install it or set {} to its executable.".format(name, variable))
    return found


def build_settings(root):
    build_dir = root / "build-pico"  # Keep the old VS Code build directory untouched.
    sdk = Path(os.environ.get("PICO_SDK_PATH", str(TOOLS / "sdk" / SDK_VERSION))).expanduser().resolve()
    if not (sdk / "pico_sdk_init.cmake").is_file():
        raise RuntimeError("Pico SDK not found at {}. Set PICO_SDK_PATH to the SDK directory.".format(sdk))
    cmake = find_tool("PICO_CMAKE", "cmake", ["cmake/{}/bin/cmake{}".format(CMAKE_VERSION, EXE)])
    ninja = find_tool("PICO_NINJA", "ninja", ["ninja/{}/ninja{}".format(NINJA_VERSION, EXE)])
    toolchain = Path(os.environ.get("PICO_TOOLCHAIN_PATH", str(TOOLS / "toolchain" / TOOLCHAIN_VERSION))).expanduser()
    compiler = find_tool("PICO_CC", "arm-none-eabi-gcc", [toolchain / "bin" / ("arm-none-eabi-gcc" + EXE)])
    # The SDK also needs g++/objcopy/etc. alongside gcc, not a host C compiler.
    compiler_dir = Path(compiler).resolve().parent
    env = os.environ.copy()
    env["PATH"] = os.pathsep.join([str(compiler_dir), str(Path(ninja).parent), str(Path(cmake).parent), env.get("PATH", "")])
    configure = [cmake, "-S", str(root), "-B", str(build_dir), "-G", "Ninja",
                 "-DPICO_BOARD=" + BOARD, "-DPICO_PLATFORM=" + CHIP,
                 "-DPICO_SDK_PATH=" + str(sdk), "-DPICO_TOOLCHAIN_PATH=" + str(compiler_dir.parent),
                 "-DCMAKE_MAKE_PROGRAM=" + ninja, "-DCMAKE_BUILD_TYPE=Debug",
                 "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON", "-DPython3_EXECUTABLE=" + sys.executable]
    # Same optional SDK utilities as before, but without pico-vscode.cmake.
    for package, default in [("picotool", TOOLS / "picotool" / SDK_VERSION / "picotool"),
                             ("pioasm", TOOLS / "tools" / SDK_VERSION / "pioasm")]:
        location = Path(os.environ.get(package.upper() + "_DIR", str(default))).expanduser()
        if location.is_dir():
            configure.append("-D{}_DIR={}".format(package, location.resolve()))
    return configure, [cmake, "--build", str(build_dir), "--target", TARGET, "--parallel"], env


def flash_command():
    openocd = find_tool("PICO_OPENOCD", "openocd", [
        "openocd/{}/openocd{}".format(OPENOCD_VERSION, EXE),
        "openocd/{}/bin/openocd{}".format(OPENOCD_VERSION, EXE)])
    parent = Path(openocd).resolve().parent
    supplied = os.environ.get("OPENOCD_SCRIPTS")
    candidates = [Path(supplied).expanduser()] if supplied else [parent / "scripts", parent.parent / "share/openocd/scripts"]
    scripts = next((p for p in candidates if (p / "interface/cmsis-dap.cfg").is_file() and (p / "target/rp2040.cfg").is_file()), None)
    if supplied and scripts is None:
        raise RuntimeError("OPENOCD_SCRIPTS must contain interface/cmsis-dap.cfg and target/rp2040.cfg.")
    speed = int(os.environ.get("PICO_SWD_SPEED", "5000"))
    if speed <= 0:
        raise RuntimeError("PICO_SWD_SPEED must be a positive speed in kHz.")
    command = [openocd]
    if scripts:
        command += ["-s", str(scripts.resolve())]
    # Run from the build directory so Tcl never has to interpret a user-supplied absolute path.
    command += ["-f", "interface/cmsis-dap.cfg", "-f", "target/" + CHIP + ".cfg",
                "-c", "adapter speed " + str(speed),
                "-c", "program " + TARGET + ".elf verify reset exit"]
    return command


def run(command, cwd, env, dry_run):
    display = subprocess.list2cmdline(command) if WINDOWS else " ".join(shlex.quote(x) for x in command)
    print("\n[{}]\n{}".format(cwd, display), flush=True)
    if not dry_run:
        subprocess.run(command, cwd=str(cwd), env=env, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["check", "build", "flash"])
    parser.add_argument("--project", default=os.getcwd(), help="project folder or source file; defaults to the current folder")
    parser.add_argument("--dry-run", action="store_true", help="show commands; do not build or contact hardware")
    args = parser.parse_args()
    root = find_project(args.project)
    build_dir = root / "build-pico"
    print("Project: {}".format(root), flush=True)
    print("Pico: {} / {} | target {} | {}".format(BOARD, CHIP, TARGET, sys.platform), flush=True)
    configure, build, env = build_settings(root)
    flash = flash_command() if args.action in ("check", "flash") else None
    dry_run = args.dry_run or args.action == "check"
    if dry_run:
        print("CHECK ONLY: no build and no connection to the probe.", flush=True)
    run(configure, root, env, dry_run)
    run(build, root, env, dry_run)
    if args.action == "flash":
        # Both subprocesses above must succeed before reaching OpenOCD.
        if not dry_run and not (build_dir / (TARGET + ".elf")).is_file():
            raise RuntimeError("Build did not produce {}.elf; refusing to flash.".format(TARGET))
        run(flash, build_dir, env, dry_run)
    elif args.action == "check":
        run(flash, build_dir, env, True)
        print("\nTool paths found. Versions, USB permissions and the actual board still need a real test.")
    print("\nPico {} finished.".format(args.action), flush=True)


if __name__ == "__main__":
    try:
        main()
    except subprocess.CalledProcessError as error:
        print("\nStopped: command exited with code {}. No subsequent command was run.".format(error.returncode), file=sys.stderr)
        sys.exit(error.returncode if error.returncode > 0 else 1)
    except (OSError, RuntimeError, ValueError) as error:
        print("\nPico: " + str(error), file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nCancelled.", file=sys.stderr)
        sys.exit(130)
