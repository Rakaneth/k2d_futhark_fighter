DBG=./out/Debug
RLS=./out/Release
EXE=masterstower #change this to match name
RENDERER="-define:KARL2D_RENDER_BACKEND=gl"
OSIZE="-o:size"

for fld in "$DBG" "$RLS"; do
    if [ ! -d $fld ]; then
        mkdir -p "$fld"
    fi
done

case $1 in
    debug)
        odin build src -debug -out:$DBG/$EXE $RENDERER
        ;;
    release)
        odin build src -out:$RLS/$EXE $RENDERER
        ;;
    web)
        odin run vendor/karl2d/build_web -- src $OSIZE
        ;;
    clean)
        rm -rf out
        if [ -d src/bin ]; then
            rm -rf src/bin
        fi

        if [ -d src/web ]; then
            rm -rf src/web
        fi
        ;;
    *)
        echo "Usage: ./build.sh (debug|release|web|clean)"
        ;;
esac
