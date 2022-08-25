#!/usr/bin/env sh

function try_ln() {
    if [[ -a $2 ]]; then
        rm -f $2
    fi
    ln -s $@
}

platform=$1

if [[ -z "$platform" ]]; then
    case `uname -s` in
        "Darwin")
            platform="macosx"
            ;;
        *)
            ;;
    esac
fi

luaversion=5.4.1

if [[ ! -d lua-src ]]; then
    mkdir lua-src
fi

# download lua

if [[ ! -a lua-src/lua-$luaversion.tar.gz ]]; then
    curl --output lua-src/lua-$luaversion.tar.gz https://www.lua.org/ftp/lua-$luaversion.tar.gz 
fi

# compile standard lua 

if [[ -d lua-src/lua-$luaversion ]]; then
    rm -rf -d lua-src/lua-$luaversion
fi

tar -xvzf lua-src/lua-$luaversion.tar.gz -C lua-src

if [[ ! -d lua-src/lua-$luaversion ]]; then
    echo "failed to unpack lua source code" >&2
    exit 2
fi

make mingw -C lua-src/lua-$luaversion $platform

if [[ $? -ne 0 ]]; then
    echo "compile standard lua failed" >&2
    exit 2
fi

try_ln $(pwd)/lua-src/lua-$luaversion/src/ standard_lua

# compile rand opcodes lua 

if [[ -d lua-src/lua-$luaversion-rand-opcodes ]]; then
    rm -rf lua-src/lua-$luaversion-rand-opcodes
fi

cp -r lua-src/lua-$luaversion lua-src/lua-$luaversion-rand-opcodes

echo 按任意键继续
read -n 1
echo 继续运行

./standard_lua/lua rand_opcodes_$luaversion.lua lua-src/lua-$luaversion-rand-opcodes/src/

echo 按任意键继续
read -n 1
echo 继续运行

if [[ $? -ne 0 ]]; then
    echo "failed to rand opcodes" >&2
    exit 2
fi

echo 按任意键继续
read -n 1
echo 继续运行

make mingw -C lua-src/lua-$luaversion-rand-opcodes clean
make mingw -C lua-src/lua-$luaversion-rand-opcodes $platform

if [[ $? -ne 0 ]]; then
    echo "compile rand opcodes lua failed" >&2
    exit 2
fi

try_ln $(pwd)/lua-src/lua-$luaversion-rand-opcodes/src/lua rand_opcodes_lua
try_ln $(pwd)/lua-src/lua-$luaversion-rand-opcodes/src/luac rand_opcodes_luac

echo 按任意键继续
read -n 1
echo 继续运行

