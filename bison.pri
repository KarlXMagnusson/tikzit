bison.name = Bison ${QMAKE_FILE_IN}
bison.input = BISONSOURCES
bison.output = ${QMAKE_FILE_PATH}/${QMAKE_FILE_BASE}.parser.cpp

win32 {
    bison.commands = win_bison.exe -d -o ${QMAKE_FILE_PATH}/${QMAKE_FILE_BASE}.parser.cpp ${QMAKE_FILE_IN}
} else {
    bison.commands = bison -d -o ${QMAKE_FILE_PATH}/${QMAKE_FILE_BASE}.parser.cpp ${QMAKE_FILE_IN}
}


bison.CONFIG += target_predeps
bison.variable_out = GENERATED_SOURCES
silent:bison.commands = @echo Bison ${QMAKE_FILE_IN} && $$bison.commands
QMAKE_EXTRA_COMPILERS += bison
bison_header.input = BISONSOURCES
bison_header.output = ${QMAKE_FILE_PATH}/${QMAKE_FILE_BASE}.parser.hpp

win32 {
    bison_header.commands = win_bison.exe -d -o ${QMAKE_FILE_PATH}/${QMAKE_FILE_BASE}.parser.cpp ${QMAKE_FILE_IN}
} else {
    bison_header.commands = bison -d -o ${QMAKE_FILE_PATH}/${QMAKE_FILE_BASE}.parser.cpp ${QMAKE_FILE_IN}
}

bison_header.CONFIG += target_predeps no_link
silent:bison_header.commands = @echo Bison ${QMAKE_FILE_IN} && $$bison.commands
QMAKE_EXTRA_COMPILERS += bison_header
